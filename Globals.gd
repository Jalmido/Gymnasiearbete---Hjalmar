extends Node

var ammo: int = 18
var lives: int = 4


func _take_damage():
	lives -= 1
