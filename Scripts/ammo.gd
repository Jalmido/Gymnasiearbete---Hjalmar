extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Globals.ammo_in_inv += 12
		queue_free()
