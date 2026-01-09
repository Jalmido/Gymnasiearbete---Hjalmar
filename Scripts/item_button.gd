extends Button
class_name ItemButton

@export var item_name: String


#id 1 = svärd
#id 2 = pickadoll

#knapparna är i en button group, för då kan bara en åt gången va aktiv

# Inuti ditt HUD/Hotbar script
func _process(_delta):
	if Globals.health_potions_in_inv > 0:
		$"../ItemButton4/Healthpotionlabel".text = "x" + str(Globals.health_potions_in_inv)
		$"../ItemButton4".icon = load("res://Assets/Items/game-potion-pixelated-free-png-2.png")
	else:
		$"../ItemButton4".icon = null
		$"../ItemButton4/Healthpotionlabel".text = ""
