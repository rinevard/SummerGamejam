extends Node2D

var paused = false
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var audio_player = $AudioStreamPlayer

func _ready():
	audio_player.play()
	Engine.time_scale = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		click_pause()

func click_pause():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
