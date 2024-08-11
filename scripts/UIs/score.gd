extends Label
class_name PopScore

var tween: Tween

@export var animation_duration: float = 0.8
@export var up_dis: float = 20

func _ready():
    # 初始化Tween
    tween = create_tween()
    
    # 设置初始属性
    modulate.a = 1.0
    
    # 创建上浮动画
    tween.tween_property(self, "position:y", position.y - up_dis, animation_duration)
    
    # 创建淡出动画
    tween.parallel().tween_property(self, "modulate:a", 0.0, animation_duration)
    
    # 动画结束后删除节点
    tween.tween_callback(queue_free)

# 设置分数文本
func set_score(bonus_score: int):
    text = "+" + str(bonus_score)