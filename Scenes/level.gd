extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	if LocationManager.last_exit_position:
		player.global_position = LocationManager.last_exit_position
	else:
		print("FINNS INGEN")
