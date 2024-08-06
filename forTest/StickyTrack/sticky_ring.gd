extends StickyTrack
class_name StickyCircle

@onready var push_collision: CollisionShape2D = $PushCollision

# 内圆半径
@export var inner_radius: float = 80.0

# 外圆半径
@export var outer_radius: float = 120.0

func _ready() -> void:
    super()
    
    if push_collision != null and push_collision.shape != null:
        if push_collision.shape is CircleShape2D:
            var circle_shape: CircleShape2D = push_collision.shape 
            outer_radius = circle_shape.radius
            inner_radius = outer_radius * 0.75  # 可以根据需要调整

func is_point_inside(point: Vector2) -> bool:
    var local_point = to_local(point) - core_position
    var distance = local_point.length()
    return distance >= inner_radius and distance <= outer_radius

func get_push_vector(point: Vector2) -> Vector2:
    var local_point = to_local(point) - core_position
    var distance = local_point.length()
    var direction = local_point.normalized().rotated(PI/2)  # 切线方向
    
    # 计算到环中心线的距离
    var distance_to_center = abs(distance - (inner_radius + outer_radius) / 2)
    var max_distance = (outer_radius - inner_radius) / 2
    
    # 根据到中心线的距离计算推力强度
    var force = max_push_force #* (1 - distance_to_center / max_distance)
    
    return direction * force

func _draw() -> void:
    draw_arc(core_position, inner_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_arc(core_position, outer_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_circle(core_position, 5, Color.RED)

func update_push_direction() -> void:
    # 圆环不需要更新推力方向，因为它是环形的
    pass