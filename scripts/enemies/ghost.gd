extends CharacterBody2D
class_name Ghost

const PUSH_ADDITION_RATIO := 100

@export var ghost_speed := 150.0
var _target_position := Vector2.ZERO
var _star_tracks : Array[StarTrack] = []
var _is_alive: bool = true

@onready var _star_detector: Area2D = $StarDetector
@onready var _player_stomp_hurt_box: Area2D = $PlayerStompHurtBox
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    add_to_group("Enemy")
    _player_stomp_hurt_box.add_to_group("EnemyHead")
    _star_detector.area_entered.connect(_on_star_detector_area_entered)
    _star_detector.area_exited.connect(_on_star_detector_area_exited)
    _animation_player.play("move")

func _physics_process(delta: float) -> void:
    var direction := global_position.direction_to(_target_position)
    velocity = direction * ghost_speed
    _apply_star_track_forces(delta)
    if _is_alive:
        move_and_slide()

func _apply_star_track_forces(delta: float) -> void:
    var total_push_vector := Vector2.ZERO
    for track in _star_tracks:
        total_push_vector += track.get_push_vector(global_position) * PUSH_ADDITION_RATIO
    velocity += total_push_vector * delta

func _on_star_detector_area_entered(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.append(area)

func _on_star_detector_area_exited(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.erase(area)

func update_target_position(target_position: Vector2) -> void:
    _target_position = target_position

func _on_player_stomp_hurt_box_area_entered(_area: Area2D) -> void:
    print("hurt")
    velocity.y = -ghost_speed
    
    die()  # 触发 ghost 的死亡逻辑

func die() -> void:
    _is_alive = false
    # 播放死亡动画
    _animation_player.play("die")
    await _animation_player.animation_finished

    queue_free()


func _on_red_wall_hurt_detector_area_entered(_area:Area2D):
    die()