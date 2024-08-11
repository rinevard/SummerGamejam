extends Control

@onready var title_label = $TitleLabel
@onready var tutorial_button = $MarginContainer/VBoxContainer/TutorialButton
@onready var start_button = $MarginContainer/VBoxContainer/StartButton
@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var tutorial_scene = preload("res://scenes/levels/tutorial.tscn")
var main_game_scene = preload("res://scenes/levels/main_game.tscn")

func _ready():
    audio_player.play()
    tutorial_button.pressed.connect(_on_tutorial_button_pressed)
    start_button.pressed.connect(_on_start_button_pressed)
    exit_button.pressed.connect(_on_exit_button_pressed)

func _on_tutorial_button_pressed():
    print("教程按钮被按下")
    get_tree().change_scene_to_packed(tutorial_scene)

func _on_start_button_pressed():
    print("开始按钮被按下")
    get_tree().change_scene_to_packed(main_game_scene)

func _on_exit_button_pressed():
    print("退出按钮被按下")
    get_tree().quit()