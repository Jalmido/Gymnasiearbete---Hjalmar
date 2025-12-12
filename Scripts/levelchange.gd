extends Node2D

@onready var change_to_underground: InteractionArea = $Change_to_underground

func _ready() -> void:
	change_to_underground.interact = Callable(self, "_on_interact")


func _on_interact():
	var player = get_tree().get_first_node_in_group("player")
	LocationManager.last_scene = "res://Scenes/overworld.tscn"
	LocationManager.last_exit_position = player.global_position
	player._Enter_underground()
	$ChangeLevelTimer.start()


func _on_change_level_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/Underground_room_1.tscn")
