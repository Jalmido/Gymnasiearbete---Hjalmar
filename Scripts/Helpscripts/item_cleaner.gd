extends Node2D

#Item cleaner ser till att man inte kan plocka upp items flera gånger.

func _ready() -> void:
	"
	Varje gång man plockar upp ett item läggs ett unikt id för det itemet till i en Global lista (picked_up_items)
	När man går in i en scen kontrollerar item cleaner i denna funktion genom att skapa samma unika id som gjordes första gången
	och om det redan finns, så tas itemet bort. (Alltså kan man inte duplicatea items)
	"
	await get_tree().process_frame
	
	var current_scene_name = get_tree().current_scene.name
	for item in get_tree().get_nodes_in_group("items"):
		var unique_id = current_scene_name + str(item.get_path()) #här skapas det unika id:t som kontrolleras i en global lista
		if unique_id in Globals.picked_up_items:
			item.queue_free()
