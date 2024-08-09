extends StickyTrack
class_name StickySquare

var push_collision: CollisionShape2D

# 方形区域的宽度
@export var width: float = 150.0

# 方形区域的高度
@export var height: float = 50.0

# 推力方向（默认为右方向）
@export var push_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	super()

	max_push_force = 200
	push_direction = push_direction.rotated(rotation)    
	create_push_collision()

func create_push_collision() -> void:
	push_collision = CollisionShape2D.new()
	push_collision.name = "PushCollision"
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(width, height)
	push_collision.shape = rect_shape
	add_child(push_collision)

func is_point_inside(point: Vector2) -> bool:
	var local_point = to_local(point) - core_position
	return abs(local_point.x) <= width / 2 and abs(local_point.y) <= height / 2

func get_push_vector(point: Vector2) -> Vector2:
	var local_point = to_local(point) - core_position
	
	var distance_to_edge = min(
		abs(width / 2 - abs(local_point.x)),
		abs(height / 2 - abs(local_point.y))
	)
	
	var force = max_push_force
	
	return push_direction * force

# 用于绘制方形区域的可视化表示（可选）
func _draw() -> void:
	var rect = Rect2(-width/2 + core_position.x, -height/2 + core_position.y, width, height)
	draw_rect(rect, Color.BLUE, false)
	draw_circle(core_position, 5, Color.RED)
	# 绘制推力方向
	draw_line(core_position, core_position + push_direction * 50, Color.GREEN, 2)

# 更新推力方向的方法（如果需要在运行时更新）
func update_push_direction() -> void:
	push_direction = Vector2.RIGHT.rotated(rotation)
