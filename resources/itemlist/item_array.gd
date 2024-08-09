extends Resource
class_name ItemArray

const MAX_SIZE = 4


@export var item_arr: Array[Item]

# test
var ring_item = preload("res://resources/items/ring_item.tres")

# test
func _init():
    item_arr = []
    item_arr.resize(MAX_SIZE)
    for i in range(MAX_SIZE):
        item_arr[i] = ring_item.duplicate()

func has_item(idx: int) -> bool:
    return idx >= 0 and idx < MAX_SIZE and item_arr[idx] != null

func delete_item(idx: int):
    if idx >= 0 and idx < MAX_SIZE:
        item_arr[idx] = null
    else:
        print("Invalid index")

func add_item(item: Item):
    for i in range(MAX_SIZE):
        if item_arr[i] == null:
            item_arr[i] = item
            return
    print("Inventory is full")


func use_item(idx: int):
    if (!has_item((idx))):
        return
    item_arr[idx].use()

func get_item_name(idx: int) -> String:
    return item_arr[idx].get_item_name()

func get_item_used_times(idx: int) -> int:
    return item_arr[idx].get_used_times()

func get_item_max_used_times(idx: int) -> int:
    return item_arr[idx].get_max_used_times()