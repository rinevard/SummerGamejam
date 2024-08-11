# flower_handler.gd
extends Node2D
class_name FlowerHandler

signal item_collected(item: Item, global_pos: Vector2)

@export var flower_scene: PackedScene = preload("res://scenes/environment/fallen_items/flower.tscn")
@export var need_random_flowers: bool = false
@export var respawn_delay: float = 15.0
@export var spawn_probability: float = 0.7

var error_radius: float = 100.0
var possible_positions: Array[Vector2] = []
var timer: Timer

func _ready() -> void:
    if not need_random_flowers:
        return
    else:
        timer = Timer.new()
        add_child(timer)
        timer.one_shot = false
        timer.timeout.connect(_on_timer_timeout)

func setup(positions: Array[Vector2]) -> void:
    possible_positions = positions
    
    if need_random_flowers:
        _spawn_random_flowers()

func spawn_flower(global_pos: Vector2) -> void:
    var flower: Node2D = flower_scene.instantiate()
    add_child(flower)
    flower.global_position = global_pos
    
    if flower.has_signal("flower_collected"):
        flower.flower_collected.connect(_on_flower_collected)
    else:
        push_warning("Flower scene does not have 'flower_collected' signal.")

func _spawn_random_flowers() -> void:
    var available_positions = possible_positions.filter(func(pos): return _is_position_empty(pos))
    available_positions.shuffle()
    
    for pos in available_positions:
        if randf() <= spawn_probability:
            spawn_flower(pos)

func _on_flower_collected(item: Item, global_pos: Vector2) -> void:
    item_collected.emit(item, global_pos)
    
    if need_random_flowers:
        if not timer.is_inside_tree():
            timer.one_shot = false
            add_child(timer)
        timer.start(respawn_delay)

func _on_timer_timeout() -> void:
    _spawn_random_flowers()

func _is_position_empty(position: Vector2) -> bool:
    for child in get_children():
        if not child.is_in_group("Flower"):
            continue
        if child.global_position.distance_to(position) <= error_radius:
            return false
    return true