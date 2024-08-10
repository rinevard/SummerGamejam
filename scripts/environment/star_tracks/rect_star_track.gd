extends StarTrack
class_name RectStarTrack

# 长方形的长度
@export var length: float = 100.0

# 长方形的宽度
@export var width: float = 30.0

# 长方形的旋转角度（度）
@export var rotation_angle: float = 0.0

# 长方形的颜色
var rect_color: Color = Color(0.2, 0.2, 0.2)  # 深灰色

func _ready() -> void:
    super()
    create_rectangle()

func setup(len: float, wid: float, angle: float, color: Color, force: float) -> void:
    """
    设置长方形的参数
    
    Args:
        len (float): 长度
        wid (float): 宽度
        angle (float): 旋转角度（度）
        color (Color): 长方形颜色
        force (float): 最大推力
    """
    length = len
    width = wid
    rotation_angle = angle
    rect_color = color
    max_push_force = force
    return

func create_rectangle() -> void:
    """
    创建长方形，包括可视化的多边形和碰撞形状
    """
    var points := PackedVector2Array([
        Vector2(-length/2, -width/2),
        Vector2(length/2, -width/2),
        Vector2(length/2, width/2),
        Vector2(-length/2, width/2)
    ])
    
    # 应用旋转
    for i in range(points.size()):
        points[i] = points[i].rotated(deg_to_rad(rotation_angle))
    
    var polygon := Polygon2D.new()
    polygon.color = rect_color
    polygon.antialiased = true
    polygon.set_polygon(points)
    add_child(polygon)

    var col_polygon := CollisionPolygon2D.new()
    col_polygon.set_polygon(points)
    add_child(col_polygon)

func is_point_inside(point: Vector2) -> bool:
    """
    检查一个点是否在长方形内
    
    Args:
        point (Vector2): 要检查的点(全局坐标)
        
    Returns:
        bool: 点在长方形内返回 true，否则返回 false
    """
    var local_point := to_local(point) - core_position
    local_point = local_point.rotated(deg_to_rad(-rotation_angle))
    return abs(local_point.x) <= length/2 and abs(local_point.y) <= width/2

func get_push_vector(point: Vector2) -> Vector2:
    """
    获取推力向量
    
    Args:
        point (Vector2): 要计算推力的点(全局坐标)
        
    Returns:  
        Vector2: 推力向量
    """
    var push_direction := Vector2.RIGHT.rotated(deg_to_rad(rotation_angle))
    return push_direction * max_push_force

func _draw() -> void:
    var points := PackedVector2Array([
        Vector2(-length/2, -width/2),
        Vector2(length/2, -width/2),
        Vector2(length/2, width/2),
        Vector2(-length/2, width/2)
    ])
    for i in range(points.size()):
        points[i] = points[i].rotated(deg_to_rad(rotation_angle))
    
    # 绘制填充的多边形
    draw_colored_polygon(points, rect_color)
    
    # 绘制轮廓
    var outline_points = points  # 创建一个新的 PackedVector2Array
    outline_points.append(points[0])  # 添加起始点以闭合多边形
    draw_polyline(outline_points, Color.BLUE, 2)
    
    # 绘制中心点
    draw_circle(core_position, 5, Color.RED)