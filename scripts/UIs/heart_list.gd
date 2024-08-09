# heart_list.gd
extends HBoxContainer

const full_heart_frame := 0
const half_heart_frame := 1
const empty_heart_frame := 2

var total_hearts := 3
var health : int
var single_heart = preload("res://scenes/UIs/heart.tscn")  # Panel

func _ready():
	create_hearts(total_hearts)
	update_health_display(3)

func setup(max_hearts):
	total_hearts = max_hearts

func create_hearts(total_hearts: int):
	health = 2 * total_hearts
	for child in get_children():
		child.queue_free()
	
	var full_hearts = health / 2
	var half_heart = health % 2
	
	for i in range(full_hearts):
		var heart = single_heart.instantiate()
		add_child(heart)
		heart.set_heart_state(full_heart_frame)  # Full heart
	
	if half_heart:
		var heart = single_heart.instantiate()
		add_child(heart)
		heart.set_heart_state(half_heart_frame)  # Half heart

# 一个心代表两滴血，半心代表一滴血
func update_health_display(new_health: int):
	health = new_health
	var full_hearts = health / 2
	var half_heart = health % 2
	
	for i in range(total_hearts):
		if i < full_hearts:
			get_child(i).set_heart_state(full_heart_frame)  # Full heart
		elif i == full_hearts and half_heart:
			get_child(i).set_heart_state(half_heart_frame)  # Half heart
		else:
			get_child(i).set_heart_state(empty_heart_frame)  # Empty heart

