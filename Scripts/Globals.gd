extends Node
signal lives_changed(new_health)

var ammo_in_mag: int = 18
var ammo_in_inv: int = 8 #testsiffra
var lives: int = 4:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)
