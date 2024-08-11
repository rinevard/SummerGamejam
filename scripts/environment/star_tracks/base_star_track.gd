extends Area2D
class_name StarTrack

# 核心位置，相对于对象的局部坐标
@export var core_position: Vector2 = Vector2.ZERO

# 推动区域的半径，可以被子类重写为其他形状
@export var push_radius: float = 100.0

# 最大推力
@export var max_push_force: float = 100.0

# 受此对象影响的其他 StarTrack
var affected_objects: Array = []

func _ready() -> void:
	add_to_group("StarTrack")

# 检查一个点是否在推动区域内
func is_point_inside(point: Vector2) -> bool:
	var local_point = to_local(point)
	return local_point.distance_to(core_position) <= push_radius

# 获取推力向量，可以被子类重写以实现不同的推力函数
func get_push_vector(point: Vector2) -> Vector2:
	"""
	Parameters:
		point: The point in global coordinates
	"""
	var local_point = to_local(point)
	var direction = (local_point - core_position).normalized()
	var distance = local_point.distance_to(core_position)
	var force = max_push_force * (1 - distance / push_radius)
	return direction * max(force, 0)

# 更新受影响的对象列表
func update_affected_objects() -> void:
	affected_objects.clear()
	var star_track_objects = get_tree().get_nodes_in_group("StarTrack")
	var flower_objects = get_tree().get_nodes_in_group("Flower")
	var red_wall_objects = get_tree().get_nodes_in_group("RedWall")

	var all_objects = star_track_objects + flower_objects + red_wall_objects
	for obj in all_objects:
		if obj != self and (obj is StarTrack or obj is Flower or obj is RedWall) and is_point_inside(obj.global_position + obj.core_position):
			affected_objects.append(obj)

# 应用推力到受影响的对象
func apply_push_force(delta: float) -> void:
	for obj in affected_objects:
		var push = get_push_vector(obj.global_position + obj.core_position)
		obj.global_position += push * delta


func _physics_process(delta: float) -> void:
	update_affected_objects()
	apply_push_force(delta)
