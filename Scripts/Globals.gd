extends Node

var ammo: int = 18
var lives: int = 4
var goblin_health: int = 5

func _take_damage():
	lives -= 1
