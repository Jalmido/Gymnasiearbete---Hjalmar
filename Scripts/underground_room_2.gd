extends Node2D


@export var enemies_required: int
@export var level_music: AudioStream
var dead_enemies = 0

func _ready():
	Globals.save_checkpoint()
	MusicManager.play_track(level_music)
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
	if dead_enemies == 3:
		$Rock_Boss.active = true
	if dead_enemies >= enemies_required:
		_on_miniboss_room_cleared()

func _on_miniboss_room_cleared():
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	Globals.miniboss_room_cleared = true
	
