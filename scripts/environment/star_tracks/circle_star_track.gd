extends StarTrack
class_name CircleStarTrack

# 圆的半径
var radius: float = 100.0 

# 圆的分段数
var seg_count: int = 72

# 圆的颜色
var circle_color: Color = Color(0.2, 0.2, 0.2)  # 深灰色

func _ready() -> void:
    super()
    create_solid_circle()

func setup(rad: float, seg: int, color: Color) -> void:
    """
    设置圆的参数
    
    Args:
        rad (float): 半径
        seg (int): 分段数
        color (Color): 圆的颜色
    """
    radius = rad
    seg_count = seg
    circle_color = color
    return

func create_solid_circle() -> void:
    """
    创建实心圆,包括可视化的多边形和碰撞形状
    """
    var angle := 360.0 / seg_count
    var points := PackedVector2Array()
    
    # 创建圆的边缘点
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
    """
    检查一个点是否在圆内
    
    Args:
        point (Vector2): 要检查的点(全局坐标)
        
    Returns:
        bool: 点在圆内返回 true,否则返回 false
    """
    var local_point := to_local(point) - core_position
    var distance := local_point.length()
    return distance <= radius

func get_push_vector(point: Vector2) -> Vector2:
    """
    获取推力向量
    
    Args:
        point (Vector2): 要计算推力的点(全局坐标)
        
    Returns:  
        Vector2: 推力向量
    """
    return Vector2.ZERO
    
func _draw() -> void:
    draw_circle(core_position, radius, Color.BLUE)
    draw_circle(core_position, 5, Color.RED)