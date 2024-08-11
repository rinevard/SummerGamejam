extends StarTrack
class_name RingStarTrack

# 圆环的内半径
@export var inner_radius: float = 50.0

# 圆环的外半径  
@export var outer_radius: float = 75.0 

# 圆环的分段数
var seg_count: int = 72

# 圆环的颜色（半透明）
var ring_color: Color = Color(0.2, 0.2, 0.2, 0.5)  # 深灰色，50% 透明度

# 向心力因子
var centripetal_force_factor: float = 0.013

@export var push_foce : float = 100.0

func _ready() -> void:
    super()
    create_circle_ring()


func setup(inner_rad: float, outer_rad: float, seg: int, force: float, color: Color) -> void:
    """
    设置圆环的参数
    
    Args:
        inner_rad (float): 内半径
        outer_rad (float): 外半径
        seg (int): 分段数
        color (Color): 圆环颜色
    """
    inner_radius = inner_rad
    outer_radius = outer_rad
    seg_count = seg
    push_foce = force
    ring_color = color
    return


func create_circle_ring() -> void:
    """
    创建圆环,包括可视化的多边形和碰撞形状
    """
    var angle := 360.0 / seg_count
    var points := PackedVector2Array()
    
    # 外点和内点在 points 中的顺序需要一个按逆时针,一个按顺时针
    # 这样才能删去中间区域
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
    
    # 确保 Polygon2D 支持透明度
    polygon.use_parent_material = false
    
    add_child(polygon)

    var col_polygon := CollisionPolygon2D.new()
    col_polygon.set_polygon(points)
    add_child(col_polygon)


func is_point_inside(point: Vector2) -> bool:
    """
    检查一个点是否在圆环内
    
    Args:
        point (Vector2): 要检查的点(全局坐标)
        
    Returns:
        bool: 点在圆环内返回 true,否则返回 false
    """
    var local_point := to_local(point) - core_position
    var distance := local_point.length()
    return distance >= inner_radius and distance <= outer_radius


func get_push_vector(point: Vector2) -> Vector2:
    """
    获取推力向量
    
    Args:
        point (Vector2): 要计算推力的点(全局坐标)
        
    Returns:  
        Vector2: 推力向量
    """
    var local_point := to_local(point) - core_position
    var direction := local_point.normalized().rotated(PI/2)
    var tangential_force := direction * push_foce
    
    # 计算向心力
    var centripetal_direction := -local_point.normalized()
    var centripetal_force := centripetal_direction * push_foce * centripetal_force_factor
    
    # 合并切向力和向心力
    return tangential_force + centripetal_force

    
func _draw() -> void:
    draw_arc(core_position, inner_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_arc(core_position, outer_radius, 0, TAU, 32, Color.BLUE, 2)
    draw_circle(core_position, 5, Color.RED)