extends CharacterBody2D
class_name Player

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const CORE_SPEED := 250.0
const DASH_SPEED := 2000.0
const PUSH_ADDITION_RATIO := 100
const WALL_STUCK_THRESHOLD := 0.15
const DEFAULT_WALL_STUCK_HELP_MOVE := 3.0 # 卡在墙里时默认的辅助移动距离

@export var item_arr: ItemArray

var wall_stuck_help_move : float = DEFAULT_WALL_STUCK_HELP_MOVE
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _in_core_mode := false
var _star_tracks : Array[StarTrack] = []
var ignore_push := false  # 用于标记是否忽略推力

# 跳跃相关变量
var remaining_jumps := 2  # 剩余跳跃次数

# 卡墙检测相关变量
var wall_stuck_timer := 0.0

signal create_ring(global_pos: Vector2)
signal create_square()

@onready var _star_detector: Area2D = $StarDetector
@onready var _player_collision: CollisionShape2D = $BoxCollision
@onready var _wall_detector: Area2D = $WallStuckDetector
@onready var _hud: CanvasLayer = $HUD

func _ready() -> void:
    _star_detector.area_entered.connect(_on_star_detector_area_entered)
    _star_detector.area_exited.connect(_on_star_detector_area_exited)
    call_deferred("_initialize_normal_mode")

func _physics_process(delta: float) -> void:
    if _in_core_mode:
        _core_move()
    else:
        _normal_move(delta)
        _check_wall_stuck(delta)
    
    if not ignore_push:  # 只在不忽略推力时应用轨道力
        _apply_star_track_forces(delta)
    
    move_and_slide()
    _check_item_usage()

func _check_item_usage() -> void:
    var item_actions := {
        "ui_q": 0,
        "ui_w": 1,
        "ui_e": 2,
        "ui_r": 3
    }
    
    for action in item_actions:
        if Input.is_action_just_pressed(action):
            var idx : int = item_actions[action]
            if item_arr and item_arr.has_item(idx):
                item_arr.use_item(idx)
                var item_name := item_arr.get_item_name(idx)
                var item_used_times := item_arr.get_item_used_times(idx)
                _use_item(action, item_name, item_used_times)
            break

func _use_item(key: String, item_name: String, used_times: int) -> void:
    # TODO: Implement item usage logic
    print("Used item: %s (Key: %s, Used times: %d)" % [item_name, key, used_times])

func _initialize_normal_mode() -> void:
    _in_core_mode = false
    _player_collision.set_deferred("disabled", false)
    remaining_jumps = 2
    print("Initialized in normal mode")

func _normal_move(delta: float) -> void:
    if is_on_floor():
        remaining_jumps = 2
    else:
        velocity.y += gravity * delta
        if remaining_jumps > 1:
            remaining_jumps = 1

    if Input.is_action_just_pressed("ui_accept") and remaining_jumps > 0:
        velocity.y = JUMP_VELOCITY
        remaining_jumps -= 1

    var direction := Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

func _core_move() -> void:
    var direction := Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )
    velocity = direction * CORE_SPEED
    
    ignore_push = Input.is_action_pressed("ui_accept")
    if ignore_push:
        velocity /= 5.0

func _apply_star_track_forces(delta: float) -> void:
    var total_push_vector := Vector2.ZERO
    for track in _star_tracks:
        total_push_vector += track.get_push_vector(global_position) * PUSH_ADDITION_RATIO
    velocity += total_push_vector * delta

func _on_star_detector_area_entered(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.append(area)
        if not _in_core_mode:
            call_deferred("_enter_core_mode")

func _on_star_detector_area_exited(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.erase(area)
        if _star_tracks.is_empty():
            call_deferred("_exit_core_mode")

func _enter_core_mode() -> void:
    if not _in_core_mode:
        _in_core_mode = true
        _player_collision.set_deferred("disabled", true)
        print("Entered core mode")

func _exit_core_mode() -> void:
    if _in_core_mode:
        _in_core_mode = false
        _player_collision.set_deferred("disabled", false)
        remaining_jumps = 1  # 从核心模式退出时重置为1次跳跃机会
        print("Exited core mode")
        
func _place_star_square() -> void:
    emit_signal("create_square")
    print("Square created")

func _place_star_ring() -> void:
    emit_signal("create_ring", global_position)
    print("Ring created at", global_position)

func _check_wall_stuck(delta: float) -> void:
    if _wall_detector.has_overlapping_bodies():
        wall_stuck_timer += delta
        if wall_stuck_timer >= WALL_STUCK_THRESHOLD:
            wall_stuck_help_move += 2.0
            _handle_wall_stuck()
            wall_stuck_timer = 0.0
    else:
        wall_stuck_help_move = DEFAULT_WALL_STUCK_HELP_MOVE
        wall_stuck_timer = 0.0

func _handle_wall_stuck() -> void:
    position += Vector2(randf_range(-wall_stuck_help_move, wall_stuck_help_move), 
                        randf_range(-wall_stuck_help_move, wall_stuck_help_move))
    velocity = Vector2.ZERO # 避免计算重力 
    print("Handled wall stuck")