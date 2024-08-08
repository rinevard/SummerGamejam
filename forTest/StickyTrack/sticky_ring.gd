extends StickyTrack
class_name StickyRing

@export var inner_radius: float = 50.0
@export var outer_radius: float = 75.0
@export var seg_count: int = 72
@export var ring_color: Color = Color(0.2, 0.2, 0.2)  # Dark gray color
@export var centripetal_force_factor: float = 0.013

func _ready() -> void:
    super()
    create_circle_ring()

func create_circle_ring() -> void:
    """
    创建圆环,包括可视化的多边形和碰撞形状。
    """
    var angle := 360.0 / seg_count
    var points := PackedVector2Array()
    
    # 外点和内点在points中的顺序需要一个按逆时针，一个按顺时针。这样才能删去中间区域。
    # 在我们的代码中，外点逆时针，内点顺时针。
    for i in range(seg_count + 1):
        var rot := float(i) * angle
        var rad_angle := deg_to_rad(rot)
        var outer_point := Vector2(sin(rad_angle) * outer_radius, cos(rad_angle) * outer_radius)
        points.append(outer_point)
    
    for i in range(seg_count, -1, -1):
        var rot := float(i) * angle
        var rad_angle := deg_to_rad(rot)
        var inner_point := Vector2(sin(rad_angle) * inner_radius, cos(rad_angle) * inner_radius)
        points.append(inner_point)
    
    var polygon := Polygon2D.new()
    polygon.color = ring_color
    polygon.antialiased = true
    polygon.set_polygon(points)
    add_child(polygon)

    var col_polygon := CollisionPolygon2D.new()
    col_polygon.set_polygon(points)
    add_child(col_polygon)

func is_point_inside(point: Vector2) -> bool:
    var local_point := to_local(point) - core_position
    var distance := local_point.length()
    return distance >= inner_radius and distance <= outer_radius

func get_push_vector(point: Vector2) -> Vector2:
    var local_point := to_local(point) - core_position
    var direction := local_point.normalized().rotated(PI/2)
    var tangential_force := direction * max_push_force
    
    # 计算向心力
    var centripetal_direction := -local_point.normalized()
    var centripetal_force := centripetal_direction * max_push_force * centripetal_force_factor
    
    # 合并切向力和向心力
    return tangential_force + centripetal_force

func _draw() -> void:
    draw_arc(core_position, inner_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_arc(core_position, outer_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_circle(core_position, 5, Color.RED)