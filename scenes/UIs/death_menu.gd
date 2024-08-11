extends CanvasLayer
class_name DeathMenu

@export var reset_path: String




func _on_quit_button_down():
	get_tree().change_scene_to_file("res://scenes/UIs/start_menu.tscn")

func _on_remake_button_down():
	get_tree().change_scene_to_file(reset_path)