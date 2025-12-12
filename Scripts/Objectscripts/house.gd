extends StaticBody2D

@onready var interaction_area: InteractionArea = $EnterHouseArea

@export var house_number: int = 1

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	var player = get_tree().get_first_node_in_group("player")
	LocationManager.last_scene = "res://Scenes/overworld.tscn"
	LocationManager.last_exit_position = player.global_position
	LocationManager._play_animation()
	$EnterHouseTimer.start()
	

"""
STÖRST PROBLEM HITTILS: felsökning för att jag spawnade vid 0,0 när jag gick ut ur huset trots att jag 
sparade enter_positionen i en global script. Problemet var att jag hade råkat stoppa
interaction_manager i samma group (player) som playern, och därmed tog den interactionmanagerns coords ist.
"""


func _on_enter_house_timer_timeout() -> void:
	LocationManager.enter_house(house_number)
