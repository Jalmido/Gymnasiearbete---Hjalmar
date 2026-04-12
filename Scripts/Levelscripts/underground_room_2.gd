extends Node2D


@export var enemies_required: int
@export var level_music: AudioStream
var dead_enemies = 0

func _ready():
	"
	Checkpoint sparas och bakgrundsmusik körs. Om man redan har klarat rummet (Global variabeln miniboss_room_cleared är true)
	så kommer fienderna tas bort direkt i _setup_cleared_room()
	Annars körs setup_miniboss_room
	"
	Globals.save_checkpoint()
	MusicManager.play_track(level_music)
	if Globals.miniboss_room_cleared:
		_setup_cleared_room()
	else:
		_setup_miniboss_room()

func _setup_cleared_room():
	"
	Dörrar låses upp och fiender/boss tas bort
	"
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	
func _setup_miniboss_room():
	"
	dörrar låses och _connect_enemy_signals() anropas
	"
	_connect_enemy_signals()
	$RoomChange._lock_door()
	$RoomChange2._lock_door()
	
func _connect_enemy_signals():
	"
	Kopplar upp till alla enemies/bossens dead signaler.
	"
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies_required = 4
	for enemy in enemies:
		enemy.dead.connect(_on_enemy_dead)
		
func _on_enemy_dead(enemy):
	"
	Varje gång en fiende dör ökar dead enemies med 1. När den är 3 (alla goblins döda), så aktiveras bossen
	När bossen dör anropas _on_miniboss_room_cleared().
	"
	dead_enemies += 1
	if dead_enemies == 3:
		$Rock_Boss.active = true
	if dead_enemies >= enemies_required:
		_on_miniboss_room_cleared()

func _on_miniboss_room_cleared():
	"
	Om man är i boss_fight_mode görs inget av detta, då victory screen dyker upp istället.
	Annars låses dörrarna upp och Global variabeln sätts till true, så att om man går tillbaka hit, så ska fienderna försvinna.
	"
	if Globals.boss_fight_mode:
		return
	$RoomChange._unlock_door()
	$RoomChange2._unlock_door()
	Globals.miniboss_room_cleared = true
	
