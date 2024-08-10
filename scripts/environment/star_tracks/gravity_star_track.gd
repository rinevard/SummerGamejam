extends StarTrack
class_name GravityStarTrack

var radius: float = 100.0 
var seg_count: int = 72
var circle_color: Color = Color(0.2, 0.2, 0.2)  # 深灰色

func _ready() -> void:
    super()
    create_solid_circle()

func setup(rad: float, seg: int, color: Color) -> void:
    radius = rad
    seg_count = seg
    circle_color = color
    create_solid_circle()

func create_solid_circle() -> void:
    var angle := 360.0 / seg_count
    var points := PackedVector2Array()
    
    for i in range(seg_count + 1):
        var rot := float(i) * angle
        var rad_angle := deg_to_rad(rot)
        var point := Vector2(sin(rad_angle) * radius, cos(rad_angle) * radius)
        points.append(point)
    
    var polygon := Polygon2D.new()
    polygon.color = circle_color
    polygon.antialiased = true
    polygon.set_polygon(points)
    add_child(polygon)

    var col_polygon := CollisionPolygon2D.new()
    col_polygon.set_polygon(points)
    add_child(col_polygon)

func is_point_inside(point: Vector2) -> bool:
    var local_point := to_local(point) - core_position
    var distance := local_point.length()
    return distance <= radius

func get_push_vector(point: Vector2) -> Vector2:
    var local_point := to_local(point) - core_position
    var distance := local_point.length()
    
    if distance <= radius:
        # 计算向心力
        var direction := -local_point.normalized()  # 朝向圆心的单位向量
        var force := max_push_force * (1 - distance / radius)  # 力随距离线性减小
        return direction * force
    else:
        return Vector2.ZERO

func _draw() -> void:
    draw_circle(core_position, radius, circle_color)
    draw_circle(core_position, 5, Color.RED)