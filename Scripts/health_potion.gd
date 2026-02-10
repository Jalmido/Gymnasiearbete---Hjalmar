extends Area2D

@export var item_id: String = " "

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Globals.lives < 4:
			Globals.lives += 1
			queue_free()
		elif Globals.lives > 3:
			Globals.health_potions_in_inv += 1
			queue_free()
