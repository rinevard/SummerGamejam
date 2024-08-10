extends Resource
class_name ItemArray

const MAX_SIZE = 4

@export var item_arr: Array[Item] = [null, null, null, null]

# test
var ring_item = preload("res://resources/items/ring_item.tres")

func has_item(idx: int) -> bool:
    print(item_arr)
    return idx >= 0 and idx < MAX_SIZE and item_arr[idx] != null

func remove_item(idx: int):
    if has_item(idx):
        item_arr[idx] = null
    else:
        print("Invalid index")

func add_item(item: Item):
    for i in range(MAX_SIZE):
        if item_arr[i] == null:
            item_arr[i] = item.duplicate()
            return
    print("Inventory is full")

func use_item(idx: int):
    if !has_item(idx):
        return
    item_arr[idx].use()

func get_item_name(idx: int) -> GlobalEnums.TrackName:
    if has_item(idx):
        return item_arr[idx].get_item_name()
    return GlobalEnums.TrackName.NONE

func get_item_clicked_times(idx: int) -> int:
    if has_item(idx):
        return item_arr[idx].get_clicked_times()
    print("no item here!")
    return 0

func get_item_texture(idx: int) -> Texture:
    if has_item(idx):
        return item_arr[idx].get_item_texture()
    return null

func is_fully_used(idx: int) -> bool:
    if has_item(idx):
        if (get_item_name(idx) == GlobalEnums.TrackName.SquareTrack):
            return get_item_clicked_times(idx) >= 2
        elif (get_item_name(idx) != GlobalEnums.TrackName.NONE):
            return get_item_clicked_times(idx) >= 1
    return false