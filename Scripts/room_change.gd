extends Node2D

@onready var interaction_area: InteractionArea = $RoomChangeArea

@export var target_scene: String 
@export var target_spawn_point_name: String = ""
@export var is_lockable: bool = false 
var is_locked: bool = false

func _ready() -> void:
	if is_lockable:
		_lock_door()
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if is_locked:
		print("LÅST")
		return
	LocationManager.last_scene = "res://Scenes/underground_room1.tscn"
	LocationManager.target_spawn_point_name = target_spawn_point_name
	LocationManager._play_animation()
	$RoomChangeTimer.start()

func _lock_door():
	is_locked = true
	interaction_area.set_deferred("monitoring", false) #Tillåt interaktion igen
	#kanske gör så att det är annan bild och grejer.
	
func _unlock_door():
	is_locked = false
	interaction_area.set_deferred("monitoring", true)


func _on_room_change_timer_timeout() -> void:
	LocationManager._enter_new_room(target_scene)
