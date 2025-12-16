extends Node2D


@export var enemies_required: int

var dead_enemies = 0

func _ready():
	_connect_enemy_signals()
	$RoomChange._lock_door()
	$RoomChange2._lock_door()
func _connect_enemy_signals():
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies_required = enemies.size()
	for enemy in enemies:
		enemy.dead.connect(_on_enemy_dead)
		
func _on_enemy_dead(enemy):
	dead_enemies += 1
	print("Enemy defeated:", enemy.name)
	if dead_enemies >= enemies_required:
		_on_miniboss_room_cleared()

func _on_miniboss_room_cleared():
	print("MINIBOSS ROOM CLEARED!")
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	# Exempel:
	# - öppna dörr
	# - spawn chest
	# - spela animation
	# - spara progress

	#$ExitDoor.open()
	#$ClearAnimationPlayer.play("RoomClear")
