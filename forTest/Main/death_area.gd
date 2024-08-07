extends Area2D

@export var shape_size: Vector2 = Vector2(100, 100)
@export var glass_color: Color = Color(1, 0, 0, 0.5)  # 半透明的红色

func _ready():
    # 创建一个矩形形状的碰撞体
    var shape = RectangleShape2D.new()
    shape.size = shape_size
    
    # 创建碰撞形状节点
    var collision_shape = CollisionShape2D.new()
    collision_shape.shape = shape
    
    # 将碰撞形状添加为子节点
    add_child(collision_shape)
    
    # 创建一个ColorRect来表示红色玻璃
    var glass = ColorRect.new()
    glass.size = shape_size
    glass.color = glass_color
    glass.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 防止ColorRect阻挡鼠标事件
    add_child(glass)
    
    # 连接信号
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D):
    _check_and_delete(area)

func _on_body_entered(body: Node2D):
    _check_and_delete(body)

func _check_and_delete(node: Node2D):
    # 检查节点是否在StickyTrack组中
    if node.is_in_group("StickyTrack"):
        print("Deleting StickyTrack: ", node.name)
        node.queue_free()