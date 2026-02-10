extends Node
signal lives_changed(new_health)

var miniboss_room_cleared = false

var visited_scenes = [] #här hamnar scener som varit activa, ifall en cutscene eller så ska spelas bara första gången man aktiverar
var picked_up_items = []


var yunion_key_collected = false
var ammo_in_mag: int = 18
var ammo_in_inv: int = 8 #testsiffra
var health_potions_in_inv = 0
var lives: int = 4:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)
