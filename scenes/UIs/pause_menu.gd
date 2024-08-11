extends CanvasLayer

@onready var main = $"../"

@export var reset_path: String

func _on_quit_button_down():
	get_tree().change_scene_to_file("res://scenes/UIs/start_menu.tscn")

func _on_resume_button_down():
	main.click_pause()


func _on_reset_button_down():
	get_tree().change_scene_to_file(reset_path)
