extends Area2D

@export var item_id: String = " "

func _on_body_entered(body: Node2D) -> void:
	"
	När man plockar upp itemet (går in i health_potionens area) skapas ett unikt id i en Global lista, som item_cleaner jämför id med för att förhindra duplication.
	Sedan läggs potionen antingen in i hotbaren, eller så healar man direkt om man har mindre än 4. 
	"
	if body.is_in_group("player"):
		
		#Samma unika ID som item cleanern letar efter skapas
		var current_scene_name = get_tree().current_scene.name
		var unique_id = current_scene_name + str(get_path())
		
		
		if not unique_id in Globals.picked_up_items:
			Globals.picked_up_items.append(unique_id)
		

		if Globals.lives < 4:
			Globals.lives += 1

		elif Globals.lives > 3:
			Globals.health_potions_in_inv += 1
		queue_free()
