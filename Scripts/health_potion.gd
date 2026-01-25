extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Globals.lives < 4:
			Globals.lives += 1
			queue_free()
		elif Globals.lives > 3:
			Globals.health_potions_in_inv += 1
			queue_free()
			#in med health potion i hotbar

		
