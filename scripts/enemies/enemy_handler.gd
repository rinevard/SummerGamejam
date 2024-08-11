# enemy_handler.gd
extends Node2D
class_name EnemyHandler

@export var ghost_scene: PackedScene = preload("res://scenes/enemies/ghost.tscn")
@export var need_random_enemies := false
@export var spawn_interval: float = 15.0

var _player_position := Vector2.ZERO
var _enemy_positions: Array[Vector2] = []
var _spawn_timers: Dictionary = {}

func _ready() -> void:
    var player = get_tree().get_nodes_in_group("Player")
    if player.size() > 0:
        player = player[0]
        player.connect("player_position_changed", _on_player_position_changed)

func setup(enemy_positions: Array[Vector2]) -> void:
    _enemy_positions = enemy_positions
    
    if need_random_enemies:
        for position in _enemy_positions:
            _spawn_timers[position] = get_tree().create_timer(spawn_interval)
            _spawn_timers[position].timeout.connect(_on_spawn_timer_timeout.bind(position))

func _on_player_position_changed(global_pos: Vector2) -> void:
    _player_position = global_pos
    _update_enemies_target_position()

func _update_enemies_target_position() -> void:
    for enemy in get_children():
        if enemy.has_method("update_target_position"):
            enemy.update_target_position(_player_position)

func spawn_enemy(enemy_scene: PackedScene, global_pos: Vector2) -> void:
    var enemy: Node2D = enemy_scene.instantiate()
    add_child(enemy)
    enemy.global_position = global_pos
    
    if enemy.has_method("update_target_position"):
        enemy.update_target_position(_player_position)

func spawn_ghost(global_pos: Vector2) -> void:
    spawn_enemy(ghost_scene, global_pos)

func _on_spawn_timer_timeout(position: Vector2) -> void:
    if need_random_enemies:
        spawn_ghost(position)
        _spawn_timers[position] = get_tree().create_timer(spawn_interval)
        _spawn_timers[position].timeout.connect(_on_spawn_timer_timeout.bind(position))