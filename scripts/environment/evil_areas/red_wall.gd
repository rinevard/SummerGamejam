extends Area2D
class_name RedWall
@export var core_position: Vector2 = Vector2.ZERO

@export var width: float = 100.0
@export var height: float = 200.0
@export var border_width: float = 2.0
@export var num_points: int = 50
@export var point_speed: float = 50.0

var collision_shape: CollisionShape2D
var visual: Node2D
var points: Array = []

class MovingPoint:
    var position: Vector2
    var velocity: Vector2
    var color: Color

    func _init(pos: Vector2, vel: Vector2, col: Color):
        position = pos
        velocity = vel
        color = col

func _ready():
    add_to_group("RedWall")
    _create_collision_shape()
    _create_visual()
    _initialize_points()

func _create_collision_shape():
    collision_shape = CollisionShape2D.new()
    var rectangle = RectangleShape2D.new()
    rectangle.size = Vector2(width, height)
    collision_shape.shape = rectangle
    add_child(collision_shape)
    # 不需要设置 collision_shape 的 global_position，因为它会自动继承父节点的位置

func _create_visual():
    visual = Node2D.new()
    add_child(visual)
    visual.z_index = -1

func _initialize_points():
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    for i in range(num_points):
        var x = rng.randf_range(border_width, width - border_width)
        var y = rng.randf_range(border_width, height - border_width)
        var vx = rng.randf_range(-1, 1)
        var vy = rng.randf_range(-1, 1)
        var color = Color(rng.randf_range(0.1, 0.3), rng.randf_range(0.1, 0.3), rng.randf_range(0.1, 0.3), 0.5)
        points.append(MovingPoint.new(Vector2(x, y), Vector2(vx, vy).normalized() * point_speed, color))

func _draw():
    # 计算绘制的偏移量，使中心位于 global_position
    var offset = Vector2(-width / 2, -height / 2)
    
    # 绘制外部红色边框
    draw_rect(Rect2(offset, Vector2(width, height)), Color.RED)
    
    # 绘制内部黑色区域
    var inner_rect = Rect2(offset + Vector2(border_width, border_width), 
                           Vector2(width - 2 * border_width, height - 2 * border_width))
    draw_rect(inner_rect, Color.BLACK)
    
    # 绘制移动的点
    for point in points:
        draw_circle(point.position + offset, 2, point.color)

func _process(delta):
    _update_points(delta)
    queue_redraw()

func _update_points(delta):
    for point in points:
        point.position += point.velocity * delta
        
        # 检查边界并反弹
        if point.position.x < border_width or point.position.x > width - border_width:
            point.velocity.x *= -1
        if point.position.y < border_width or point.position.y > height - border_width:
            point.velocity.y *= -1
        
        # 确保点不会越过边界
        point.position.x = clamp(point.position.x, border_width, width - border_width)
        point.position.y = clamp(point.position.y, border_width, height - border_width)