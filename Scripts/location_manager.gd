extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer


var last_exit_position: Vector2
var last_scene: String = ""

var last_jump_position: Vector2

func _play_animation() -> void:
	anim.play("Fade_to_black")

########## IN I HUS ############

func enter_house(house_number: int) -> void:
	var scene_path = "res://Scenes/house_%d_interior.tscn" % house_number
	get_tree().change_scene_to_file(scene_path)
	anim.play("Fade_to_level")

########### UT UR HUS ###########
func _exit_house() -> void:
	get_tree().change_scene_to_file(LocationManager.last_scene)
	anim.play("Fade_to_level")
	
