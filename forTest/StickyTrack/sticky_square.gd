extends StickyTrack
class_name StickySquare

@onready var push_collision: CollisionShape2D = $PushCollision

# 方形区域的宽度
@export var width: float = 200.0

# 方形区域的高度
@export var height: float = 200.0

# 推力方向（默认为右方向）
@export var push_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
    # 调用父类的 _ready 函数
    super()
    
    # 根据节点的旋转调整推力方向
    push_direction = push_direction.rotated(rotation)
    
	# 从碰撞形状获取宽度和高度
    if push_collision != null and push_collision.shape != null:
        if push_collision.shape is RectangleShape2D:
            var rect_shape: RectangleShape2D = push_collision.shape 
            width = rect_shape.size.x
            height = rect_shape.size.y

# 重写检查点是否在推动区域内的方法
func is_point_inside(point: Vector2) -> bool:
    var local_point = to_local(point) - core_position
    return abs(local_point.x) <= width / 2 and abs(local_point.y) <= height / 2

# 重写获取推力向量的方法
func get_push_vector(point: Vector2) -> Vector2:
    var local_point = to_local(point) - core_position
    
    # 计算到边缘的距离
    var distance_to_edge = min(
        abs(width / 2 - abs(local_point.x)),
        abs(height / 2 - abs(local_point.y))
    )
    
    # 根据到边缘的距离计算推力强度
    var force = max_push_force * (distance_to_edge / min(width, height))
    
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