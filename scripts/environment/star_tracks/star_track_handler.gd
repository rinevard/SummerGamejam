# star_track_handler.gd
extends Node2D

# for all tracks
@export var default_color: Color = Color(0.2, 0.2, 0.2)  # Dark gray color
@export var max_push_force: float = 100.0

# for all circle shape
@export var seg_count: int = 72

# for circle track
@export var circle_radius: float = 65.0

# for gravity circle track
@export var gravity_circle_radius: float = 50.0
@export var gravity_centripetal_force: float = 20.0

# for ring track
@export var inner_radius: float = 50.0
@export var outer_radius: float = 75.0

# for speed track
@export var speed_length: float = 60.0
@export var speed_width: float = 40.0
@export var speed_force: float = 100.0

# for square track
@export var square_width: float = 40.0
@export var square_force: float = 30.0

var player_created_tracks := {}

# All are Area2D
var circle_star_track = preload("res://scenes/environment/star_tracks/circle_star_track.tscn")
var gravity_star_track = preload("res://scenes/environment/star_tracks/gravity_star_track.tscn")
var ring_star_track = preload("res://scenes/environment/star_tracks/ring_star_track.tscn")
var general_rectangle_star_track = preload("res://scenes/environment/star_tracks/rect_star_track.tscn") # Speed and Square can both use this to create

func _ready() -> void:
	pass

func create_circle_star_track(key: String, 
							  global_pos: Vector2, 
							  rad: float = circle_radius, 
							  seg: int = seg_count, 
							  color: Color = default_color) -> void:
	"""
	key is in ["ui_q", "ui_w", "ui_e", "ui_r"]
	"""
	var circle: CircleStarTrack = circle_star_track.instantiate()
	circle.setup(rad, seg, color)
	circle.global_position = global_pos
	add_child(circle)
	player_created_tracks[key] = circle

func create_gravity_circle_track(key: String, 
								 global_pos: Vector2, 
								 rad: float = gravity_circle_radius, 
								 seg: int = seg_count, 
								 color: Color = default_color) -> void:
	var gravity_circle: GravityStarTrack = gravity_star_track.instantiate()
	gravity_circle.setup(rad, seg, color)
	gravity_circle.global_position = global_pos
	add_child(gravity_circle)
	player_created_tracks[key] = gravity_circle

func create_ring_star_track(key: String, 
							global_pos: Vector2, 
							inner_rad: float = inner_radius, 
							outer_rad: float = outer_radius, 
							seg: int = seg_count, 
							color: Color = default_color) -> void:
	var ring: RingStarTrack = ring_star_track.instantiate()
	ring.setup(inner_rad, outer_rad, seg, color)
	ring.global_position = global_pos
	add_child(ring)
	player_created_tracks[key] = ring

func create_speed_track(key: String, global_pos: Vector2, direction: Vector2) -> void:
	var speed_track: RectStarTrack = general_rectangle_star_track.instantiate()
	var angle = rad_to_deg(direction.angle())
	speed_track.setup(speed_length, speed_width, angle, default_color, speed_force)
	speed_track.global_position = global_pos
	add_child(speed_track)
	player_created_tracks[key] = speed_track

func create_square_track(key: String, st_global_pos: Vector2, ed_global_pos: Vector2) -> void:
	var rect_track: RectStarTrack = general_rectangle_star_track.instantiate()
	var diff = ed_global_pos - st_global_pos
	var length = diff.length()
	var angle = rad_to_deg(diff.angle())
	
	# 使用轨道的中点作为其位置
	var center = (st_global_pos + ed_global_pos) / 2
	
	rect_track.setup(length, square_width, angle, default_color, square_force)
	rect_track.global_position = center
	add_child(rect_track)
	player_created_tracks[key] = rect_track

func _on_player_create_circle_track(action: String, global_pos: Vector2) -> void:
	create_circle_star_track(action, global_pos)

func _on_player_create_gravity_circle_track(action: String, global_pos: Vector2) -> void:
	create_gravity_circle_track(action, global_pos)

func _on_player_create_ring_track(action: String, global_pos: Vector2) -> void:
	create_ring_star_track(action, global_pos)

func _on_player_create_speed_track(action: String, global_pos: Vector2, direction: Vector2) -> void:
	create_speed_track(action, global_pos, direction)

func _on_player_create_square_track(action: String, st_global_pos: Vector2, ed_global_pos: Vector2) -> void:
	create_square_track(action, st_global_pos, ed_global_pos)

func _on_player_remove_track(key: String) -> void:
	if player_created_tracks.has(key):
		var track = player_created_tracks[key]
		track.queue_free()
		player_created_tracks.erase(key)