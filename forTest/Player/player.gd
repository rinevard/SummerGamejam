extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const CORE_SPEED := 350.0
const DASH_SPEED := 2000.0
const PUSH_ADDITION_RATIO := 100

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _in_core_mode := false
var _sticky_tracks: Array[StickyTrack] = []

@onready var _sticky_detector: Area2D = $StickyDetector
@onready var _player_collision: CollisionShape2D = $BoxCollision

func _ready() -> void:
    _sticky_detector.area_entered.connect(_on_sticky_detector_area_entered)
    _sticky_detector.area_exited.connect(_on_sticky_detector_area_exited)
    call_deferred("_initialize_normal_mode")

func _physics_process(delta: float) -> void:
    if _in_core_mode:
        _core_move()
    else:
        _normal_move(delta)
    
    _apply_sticky_track_forces(delta)
    move_and_slide()

func _initialize_normal_mode() -> void:
    _in_core_mode = false
    _player_collision.set_deferred("disabled", false)
    print("Initialized in normal mode")

func _normal_move(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var direction := Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

func _core_move() -> void:
    var direction := Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )
    velocity = direction * CORE_SPEED

func _apply_sticky_track_forces(delta: float) -> void:
    var total_push_vector := Vector2.ZERO
    for track in _sticky_tracks:
        total_push_vector += track.get_push_vector(global_position) * PUSH_ADDITION_RATIO
    velocity += total_push_vector * delta

func _on_sticky_detector_area_entered(area: Node2D) -> void:
    if area is StickyTrack:
        _sticky_tracks.append(area)
        if not _in_core_mode:
            call_deferred("_enter_core_mode")

func _on_sticky_detector_area_exited(area: Node2D) -> void:
    if area is StickyTrack:
        _sticky_tracks.erase(area)
        if _sticky_tracks.is_empty():
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
        print("Exited core mode")