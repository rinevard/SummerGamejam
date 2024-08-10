extends Resource
class_name Item

@export var name: GlobalEnums.TrackName
@export var icon: Texture
@export var clicked_times: int = 0

func use() -> void:
    clicked_times += 1
    return

func get_item_name() -> GlobalEnums.TrackName:
    return name

func get_clicked_times() -> int:
    return clicked_times