# star_track_handler.gd
extends Node2D

@export var inner_radius: float = 50.0
@export var outer_radius: float = 75.0
@export var seg_count: int = 72
@export var ring_color: Color = Color(0.2, 0.2, 0.2)  # Dark gray color
@export var centripetal_force_factor: float = 0.013

var player_created_tracks := {}
var ring_star_track = preload("res://scenes/environment/star_tracks/ring_star_track.tscn")  # 预加载 RingStarTrack (Area2D) 场景

func _ready():
    pass

func create_ring_star_track(key: String, global_pos: Vector2, 
                            inner_rad: float=inner_radius, 
                            outer_rad: float=outer_radius, 
                            seg: int=seg_count, 
                            color: Color=ring_color, 
                            force: float=centripetal_force_factor):
    var ring = ring_star_track.instantiate()
    ring.setup(inner_rad, outer_rad, seg, color, force)  # 调用 RingStarTrack 的设置方法
    ring.global_position = global_pos
    add_child(ring)
    player_created_tracks[key] = ring

func create_speed_star_track(key: String, pos: Vector2, direc: Vector2):
    print("create speed star track!")
    pass

func _on_player_create_ring(key: String, global_pos:Vector2):
    create_ring_star_track(key, global_pos)