extends Node2D


@export var enemies_required: int

var dead_enemies = 0

func _ready():
	if Globals.miniboss_room_cleared:
		_setup_cleared_room()
	else:
		_setup_miniboss_room()

func _setup_cleared_room():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	
func _setup_miniboss_room():
	_connect_enemy_signals()
	$RoomChange._lock_door()
	$RoomChange2._lock_door()
	
func _connect_enemy_signals():
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies_required = 4
	for enemy in enemies:
		enemy.dead.connect(_on_enemy_dead)
		
func _on_enemy_dead(enemy):
	dead_enemies += 1
	print("Enemy defeated:", enemy.name)
	print(dead_enemies)
	if dead_enemies == 3:
		$Rock_Boss.active = true
	if dead_enemies >= enemies_required:
		_on_miniboss_room_cleared()

func _on_miniboss_room_cleared():
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	print("MINIBOSS ROOM CLEARED!")
	Globals.miniboss_room_cleared = true
	# Exempel:
	# - öppna dörr
	# - spawn chest
	# - spela animation
	# - spara progress

	#$ExitDoor.open()
	#$ClearAnimationPlayer.play("RoomClear")
