extends Node2D

@onready var interaction_area: InteractionArea = $RoomChangeArea

@export var target_scene: String 
@export var target_spawn_point_name: String = ""
@export var is_lockable: bool = false 
var is_locked: bool = false

func _ready() -> void:
	"
	Dörrar kan låsas vid exempelvis bossfight. Callable funktionen från interaction_arean definieras som _on_interact i denna script
	"
	if is_lockable:
		_lock_door()
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	"
	Anropas vid interaktion med interaction_arean room_change. 
	Byter scen till export varen target scene och stoppar playern på target spawn point (en marker2d i target scenen med samma namn som export varen.)
	"
	if is_locked:
		return 
	LocationManager.target_spawn_point_name = target_spawn_point_name
	LocationManager._play_animation()
	$RoomChangeTimer.start()

func _lock_door():
	"
	Man kan ej interagera med dörrens room_change area. 
	Låses i ready om export var is_lockable är true. 
	"
	is_locked = true
	interaction_area.set_deferred("monitoring", false) 
	
	
func _unlock_door():
	"
	Man kan nu interagera med dörrens room_change area igen.
	Anropas från underground_room_2.gd när signalen att rock_boss är död tas emot.
	"
	is_locked = false
	interaction_area.set_deferred("monitoring", true) #Tillåt interaktion igen


func _on_room_change_timer_timeout() -> void:
	"
	När man interagerar med dörren för att byta rum, startas timer som här får timeout och byter scen.
	"
	LocationManager._enter_new_room(target_scene)
