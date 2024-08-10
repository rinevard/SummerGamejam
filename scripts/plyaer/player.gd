extends CharacterBody2D
class_name Player

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const CORE_SPEED := 250.0
const DASH_SPEED := 2000.0
const PUSH_ADDITION_RATIO := 100
const WALL_STUCK_THRESHOLD := 0.15
const DEFAULT_WALL_STUCK_HELP_MOVE := 3.0  # 卡在墙里时默认的辅助移动距离
const CLICKS_TO_BUILD_TRACK : Dictionary = {
    GlobalEnums.TrackName.CircleTrack: 1,
    GlobalEnums.TrackName.GravityCircleTrack: 1,
    GlobalEnums.TrackName.RingTrack: 1,
    GlobalEnums.TrackName.SpeedTrack: 1,
    GlobalEnums.TrackName.SquareTrack: 2
}
const ACTION_TO_INDEX := {
    "ui_q": 0,
    "ui_w": 1,
    "ui_e": 2,
    "ui_r": 3
}

@export var item_arr: ItemArray

var wall_stuck_help_move : float = DEFAULT_WALL_STUCK_HELP_MOVE
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _in_core_mode := false
var _star_tracks : Array[StarTrack] = []
var ignore_push := false  # 用于标记是否忽略推力
var start_global_pos_for_square_track : Dictionary = {
    "ui_q": null, 
    "ui_w": null, 
    "ui_e": null, 
    "ui_r": null
}

# 跳跃相关变量
var remaining_jumps := 2  # 剩余跳跃次数

# 卡墙检测相关变量
var wall_stuck_timer := 0.0
enum TrackName {
    CircleTrack,
    GravityCircleTrack, 
    RingTrack,
    SpeedTrack, 
    SquareTrack
}

# 连接HUD
signal player_health_changed(new_health: int)
# 这个信号发给handler提醒它移除星轨
signal remove_track(action: String)
# 这几个create_track发给handler提醒它创建星轨
signal create_circle_track(action: String, global_pos: Vector2)
signal create_gravity_circle_track(action: String, global_pos: Vector2)
signal create_ring_track(action: String, global_pos: Vector2)
signal create_speed_track(action: String, global_pos: Vector2, direction: Vector2) # 角度而非弧度
signal create_square_track(action: String, st_global_pos: Vector2, ed_global_pos: Vector2)
signal item_arr_updated() # 发给HUD提醒它更新道具显示

@onready var _star_detector: Area2D = $StarDetector
@onready var _player_collision: CollisionShape2D = $BoxCollision
@onready var _wall_detector: Area2D = $WallStuckDetector
@onready var _hud: CanvasLayer = $HUD

































func _ready() -> void:
    _star_detector.area_entered.connect(_on_star_detector_area_entered)
    _star_detector.area_exited.connect(_on_star_detector_area_exited)
    call_deferred("_initialize_normal_mode")
    test_ready()

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





func test_ready():
    var circle_item = preload("res://resources/items/circle_item.tres")
    var gravity_item = preload("res://resources/items/gravity_item.tres")
    var ring_item = preload("res://resources/items/ring_item.tres")
    var speed_item = preload("res://resources/items/speed_item.tres")
    var square_item = preload("res://resources/items/square_item.tres")
    _add_item(ring_item.duplicate())
    _add_item(square_item.duplicate())
    _add_item(square_item.duplicate())
    _add_item(square_item.duplicate())
    _add_item(ring_item.duplicate())
    _remove_item("ui_w")
    emit_signal("item_arr_updated")









func _check_item_usage() -> void:
    for action in ACTION_TO_INDEX:
        if Input.is_action_just_pressed(action):
            var item_idx : int = ACTION_TO_INDEX[action]
            if item_arr and item_arr.has_item(item_idx):
                _use_item(action)
            break

func _remove_item(action: String):
    """
    action should in ["ui_q", "ui_w", "ui_e", "ui_r"]
    """
    var item_idx: int = ACTION_TO_INDEX[action]
    assert((item_arr.has_item(item_idx)), "no item here!")
    item_arr.remove_item(item_idx)
    emit_signal("item_arr_updated")
    emit_signal("remove_track", action)

func _add_item(item: Item):
    item_arr.add_item(item.duplicate())
    emit_signal("item_arr_updated")

func _use_item(action: String) -> void:
    var item_idx : int = ACTION_TO_INDEX[action]
    if (!item_arr.has_item(item_idx)):
        return
    var item_name : GlobalEnums.TrackName = item_arr.get_item_name(item_idx)
    var clicked_times : int = item_arr.get_item_clicked_times(item_idx)
    
    if clicked_times == CLICKS_TO_BUILD_TRACK[item_name]:
        # Track has been built, remove it
        print("removing...")
        _remove_item(action)
        start_global_pos_for_square_track[action] = null
        return
    
    match item_name:
        GlobalEnums.TrackName.CircleTrack:
            emit_signal("create_circle_track", action, global_position)
        GlobalEnums.TrackName.GravityCircleTrack:
            emit_signal("create_gravity_circle_track", action, global_position)
        GlobalEnums.TrackName.RingTrack:
            emit_signal("create_ring_track", action, global_position)
        GlobalEnums.TrackName.SpeedTrack:
            var direction = get_place_track_direction()
            emit_signal("create_speed_track", action, global_position, direction)
        GlobalEnums.TrackName.SquareTrack:
            if clicked_times == 0:
                start_global_pos_for_square_track[action] = global_position
            elif clicked_times == 1:
                var start_pos = start_global_pos_for_square_track[action]
                if start_pos:
                    emit_signal("create_square_track", action, start_pos, global_position)
                    start_global_pos_for_square_track[action] = null
    
    print("Used item: %s (action: %s, Used times: %d)" % [item_name, action, clicked_times])
    item_arr.use_item(item_idx)
    emit_signal("item_arr_updated")
    return 

func get_place_track_direction() -> Vector2:
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    
    if input_vector != Vector2.ZERO:
        # 如果有输入，使用输入方向
        return input_vector.normalized()
    elif velocity != Vector2.ZERO:
        # 如果正在移动，使用当前移动方向
        return velocity.normalized()
    else:
        # 如果静止，使用面朝方向（这里假设 rotation 表示面朝方向）
        return Vector2.RIGHT.rotated(rotation)

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