extends Area2D


func _on_body_entered(body:Node2D):
    if body.is_in_group("Player"):
        body.die()
	

func _on_area_entered(area:Area2D):
    if area.is_in_group("FlowerDetector"):
        if area.get_parent().is_in_group("Player"):
            area.get_parent().die()
	
