extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label: Label = $Label

const default_text = "[E] to "

var active_areas = [] #alla nuvarande areor som kan interageras med
var can_interact = true #alla areor ska bli interagerbara när player är nära.

func register_area(area: InteractionArea):
	active_areas.append(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area) #Indexen för arean som ska ta bort ur nurvarande areor sparas i index variabeln
	if index != -1: #inte -1 för det innebär att listan ör tom
		active_areas.remove_at(index) #testade först erase(), men den tog bara bort första förekomsten, sen testade jag pop_at(), men den returnerade det borttagna värdet, vilket itn  behövs för dessa dörrar

func _process(_delta: float):
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player) #använder egna funktionnen där avståndet mellan spelarn och areorna jämförs och tar sedan första index
		#fixa labeln snyggt över arean
		label.text = default_text + active_areas[0].action_name #action name är exportvariabeln som kan ändras t lite vad som
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 20
		label.global_position.x -= label.size.x / 2
		#Positioneringen ovanförs gör så den hamnar snyggt
		label.show() 
	else:
		label.hide()
		
func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player

func _input(event: InputEvent):
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			await active_areas[0].interact.call()
			can_interact = true
