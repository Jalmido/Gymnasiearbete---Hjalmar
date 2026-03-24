extends Button
class_name ItemButton

@export var item_name: String


func _process(_delta):
	if Globals.health_potions_in_inv > 0:
		$"../HealthPotion/Healthpotionlabel".text = "x" + str(Globals.health_potions_in_inv)
		$"../HealthPotion".icon = load("res://Assets/Items/game-potion-pixelated-free-png-2.png")
	
	else:
		$"../HealthPotion".icon = null
		$"../HealthPotion/Healthpotionlabel".text = ""
	if Globals.yunion_key_collected == true:
		$"../Yunion_key".icon = load("res://Assets/Underwater/Legacy Collection/Assets/Packs/Meta data assets files/Visuals/OBJECTS/items/key.png")
		
