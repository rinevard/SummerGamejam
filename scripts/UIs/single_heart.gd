# single_heart.gd
extends Panel

@onready var sprite = $Sprite2D

func set_heart_state(state: int):
    sprite.frame = state  # 0: empty, 1: half, 2: full