extends CanvasLayer

const ITEM_ARR_SIZE = 4
@export var item_arr: ItemArray
@export var default_texture: Texture2D

@onready var heart_list: HBoxContainer = $VBoxContainer/HeartList
@onready var q_texturerect: TextureRect = $VBoxContainer/VBoxContainer/QContainer/TextureRect
@onready var w_texturerect: TextureRect = $VBoxContainer/VBoxContainer/WContainer/TextureRect
@onready var e_texturerect: TextureRect = $VBoxContainer/VBoxContainer/EContainer/TextureRect
@onready var r_texturerect: TextureRect = $VBoxContainer/VBoxContainer/RContainer/TextureRect
@onready var q_label: Label = $VBoxContainer/VBoxContainer/QContainer/Label
@onready var w_label: Label = $VBoxContainer/VBoxContainer/WContainer/Label
@onready var e_label: Label = $VBoxContainer/VBoxContainer/EContainer/Label
@onready var r_label: Label = $VBoxContainer/VBoxContainer/RContainer/Label

var container_textures: Array[TextureRect]
var container_labels: Array[Label]

func _ready() -> void:
    container_textures = [q_texturerect, w_texturerect, e_texturerect, r_texturerect]
    container_labels = [q_label, w_label, e_label, r_label]
    
    # 初始化物品显示
    _on_item_arr_updated()

func _on_item_arr_updated() -> void:
    for i in range(ITEM_ARR_SIZE):
        if item_arr.has_item(i):
            container_textures[i].texture = item_arr.get_item_texture(i)
            if item_arr.is_fully_used(i):
                # 改变对应图片透明度，显示label
                container_textures[i].modulate.a = 0.5
                container_labels[i].show()
            else:
                container_textures[i].modulate.a = 1.0
                container_labels[i].hide()
        else:
            container_textures[i].texture = default_texture
            container_textures[i].modulate.a = 1.0
            container_labels[i].hide()

func _on_player_health_changed(new_health: int) -> void:
    heart_list.update_health_display(new_health)