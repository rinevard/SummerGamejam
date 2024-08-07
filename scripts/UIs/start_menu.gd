extends Control

@onready var texture_rect = $TextureRect
@onready var title_label = $TitleLabel
@onready var tutorial_button = $MarginContainer/VBoxContainer/TutorialButton
@onready var start_button = $MarginContainer/VBoxContainer/StartButton
@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton

var tutorial_path: String = "res://scenes/levels/tutorial.tscn"
var main_game_path: String = "res://scenes/levels/main_game.tscn"

func _ready():
    # 连接按钮信号
    tutorial_button.pressed.connect(_on_tutorial_button_pressed)
    start_button.pressed.connect(_on_start_button_pressed)
    exit_button.pressed.connect(_on_exit_button_pressed)
    
    # 设置标题
    title_label.text = "我的游戏"
    
    # 可以在这里设置背景纹理
    # texture_rect.texture = preload("res://path/to/your/background_image.png")

func _on_tutorial_button_pressed():
    print("教程按钮被按下")
    get_tree().change_scene_to_file(tutorial_path)

func _on_start_button_pressed():
    print("开始按钮被按下")
    get_tree().change_scene_to_file(main_game_path)

func _on_exit_button_pressed():
    print("退出按钮被按下")
    # 退出游戏
    get_tree().quit()