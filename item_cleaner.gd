extends Node2D

#Item cleaner ser till att man inte kan plocka upp items flera gånger.

func _ready() -> void:
	await get_tree().process_frame
	
	var current_scene_name = get_tree().current_scene.name
	for item in get_tree().get_nodes_in_group("items"):
		var unique_id = current_scene_name + str(item.get_path()) #här skapas det unika id:t som kontrolleras i en global lista
		if unique_id in Globals.picked_up_items:
			item.queue_free()
