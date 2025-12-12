extends Node2D

@onready var interaction_area: InteractionArea = $RoomChangeArea

@export var room_number: int = 1

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	print("Interactar room switch")
	var player = get_tree().get_first_node_in_group("player")
	LocationManager.last_scene = "res://Scenes/underground_room1.tscn"
	LocationManager.last_exit_position = player.global_position
	LocationManager._play_animation()
	$RoomChangeTimer.start()





func _on_room_change_timer_timeout() -> void:
	LocationManager._enter_next_room(room_number + 1)
