extends Node
signal lives_changed(new_health)

var ammo: int = 18
var lives: int = 4:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)
