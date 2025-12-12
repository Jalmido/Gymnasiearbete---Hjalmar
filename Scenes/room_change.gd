extends Node2D

@onready var interaction_area: InteractionArea = $RoomChangeArea

@export var target_scene: String 
@export var target_spawn_point_name: String = ""

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	LocationManager.last_scene = "res://Scenes/underground_room1.tscn"
	LocationManager.target_spawn_point_name = target_spawn_point_name
	LocationManager._play_animation()
	$RoomChangeTimer.start()



func _on_room_change_timer_timeout() -> void:
	LocationManager._enter_new_room(target_scene)
