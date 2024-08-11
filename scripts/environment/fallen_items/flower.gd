# flower.gd
extends Area2D
class_name Flower

signal flower_collected(item: Item, global_pos: Vector2)

@export var swing_amplitude: float = 15.0  # 摇摆幅度（角度）
@export var swing_frequency: float = 2.0   # 摇摆频率（每秒摆动次数）
@export var core_position: Vector2 = Vector2.ZERO
@export var fix_item: Item # 在教程中，我们希望指定道具

var possible_items: Array[Item] = []

var time_elapsed: float = 0.0

func _ready() -> void:
    add_to_group("Flower")
    
    # 初始化可能的道具
    possible_items = [
        preload("res://resources/items/circle_item.tres"),
        preload("res://resources/items/gravity_item.tres"),
        preload("res://resources/items/ring_item.tres"),
        preload("res://resources/items/speed_item.tres"),
        preload("res://resources/items/square_item.tres")
    ]

func _process(delta: float) -> void:
    time_elapsed += delta
    
    # 使用正弦函数计算当前的旋转角度
    var swing_angle: float = swing_amplitude * sin(time_elapsed * swing_frequency * 2 * PI)
    
    # 设置节点的旋转
    rotation_degrees = swing_angle

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        _fall_item()


func _on_area_entered(area:Area2D):
    if area.is_in_group("FlowerDetector"):
        _fall_item()


func _fall_item() -> void:
    var fallen_item: Item = null

    if fix_item:
        fallen_item = fix_item.duplicate()
    elif not possible_items.is_empty():
        fallen_item = possible_items[randi() % possible_items.size()].duplicate()

    if fallen_item:
        emit_signal("flower_collected", fallen_item, global_position)
        queue_free()  # 删除 Flower 节点