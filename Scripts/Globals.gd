extends Node
signal lives_changed(new_health)

var miniboss_room_cleared = false

var ammo_in_mag: int = 18
var ammo_in_inv: int = 8 #testsiffra
var health_potions_in_inv = 0
var lives: int = 4:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)
