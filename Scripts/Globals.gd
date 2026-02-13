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

var checkpoint_data = {}

func save_checkpoint():
	checkpoint_data = {
		"lives": lives,
		"ammo_in_mag": ammo_in_mag,
		"ammo_in_inv": ammo_in_inv,
		"health_potions": health_potions_in_inv
	}


func load_checkpoint():
	if checkpoint_data.is_empty():
		return # Ingen checkpoint sparad än
		
	lives = checkpoint_data["lives"]
	ammo_in_mag = checkpoint_data["ammo_in_mag"]
	ammo_in_inv = checkpoint_data["ammo_in_inv"]
	health_potions_in_inv = checkpoint_data["health_potions"]
