# main_game.gd
extends Node2D

var paused = false

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var flower_handler: FlowerHandler = $FlowerHandler
@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
    audio_player.play()
    Engine.time_scale = 1
    setup_enemy_positions()
    setup_flower_positions()

func setup_enemy_positions() -> void:
    var enemy_positions: Array[Vector2] = []
    for marker in $EnemyMarkers.get_children():
        enemy_positions.append(marker.global_position)
    enemy_handler.setup(enemy_positions)

func setup_flower_positions() -> void:
    var possible_positions: Array[Vector2] = []
    for floor in $FlowerMarkers.get_children():
        for marker in floor.get_children():
            possible_positions.append(marker.global_position)
    flower_handler.setup(possible_positions)

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        click_pause()

func click_pause() -> void:
    paused = !paused
    if paused:
        pause_menu.show()
        Engine.time_scale = 0
    else:
        pause_menu.hide()
        Engine.time_scale = 1