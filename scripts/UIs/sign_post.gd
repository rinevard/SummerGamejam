extends Area2D

@onready var post: Panel = $Panel
@onready var label: Label = $Panel/Label

@export var text: String

func _ready():
    post.hide()

func _on_body_entered(body:Node2D):
    if body.is_in_group("Player") and label:
        post.show()
        label.text = text

func _on_body_exited(body:Node2D):
    if body.is_in_group("Player"):
        post.hide()

func _on_area_entered(area:Area2D):
    if area.is_in_group("FlowerDetector") and label:
        post.show()
        label.text = text

func _on_area_exited(area:Area2D):
    if area.is_in_group("FlowerDetector"):
        post.hide()
