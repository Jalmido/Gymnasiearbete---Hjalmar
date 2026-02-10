extends Area2D

@export var item_id: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.ammo_in_inv += 12
		Globals.picked_up_items.append(item_id)
		print(Globals.picked_up_items)
		queue_free()
