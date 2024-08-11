extends CanvasLayer

@onready var main = $"../"


func _on_quit_button_down():
	get_tree().change_scene_to_file("res://scenes/UIs/start_menu.tscn")

func _on_resume_button_down():
	main.click_pause()
