extends Resource
class_name Item

@export var name: String
@export var icon: Texture
@export var max_used_times: int
var cur_used_times: int

func use() -> void:
    cur_used_times += 1
    return

func get_item_name() -> String:
    return name

func get_used_times() -> int:
    return cur_used_times

func get_max_used_times() -> int:
    return max_used_times