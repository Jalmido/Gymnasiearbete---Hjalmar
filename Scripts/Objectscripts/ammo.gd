extends Area2D

@export var item_id: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#Unikt id skapas som sedan letas efter i itemcleaner för att se om den är plockad eller ej
		var current_scene_name = get_tree().current_scene.name
		var unique_id = current_scene_name + str(get_path()) 
		

		if not unique_id in Globals.picked_up_items:
			Globals.picked_up_items.append(unique_id)
		
		Globals.ammo_in_inv += 12
		Globals.picked_up_items.append(item_id)
		queue_free()
