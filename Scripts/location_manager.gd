extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

var last_exit_position: Vector2
var last_scene: String
var last_jump_position: Vector2
var target_spawn_point_name: String = ""


func _play_animation() -> void:
	anim.play("Fade_to_black")

func _play_animation2() -> void:
	anim.play("Fade_to_level")
	
########## IN I HUS ############

func enter_house(house_number: int) -> void:
	var target_scene = "res://Scenes/Houses/house_%d_interior.tscn" % house_number
	get_tree().change_scene_to_file(target_scene)
	anim.play("Fade_to_level")

########### UT UR HUS ###########
func _exit_house() -> void:
	get_tree().change_scene_to_file(LocationManager.last_scene)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	player.global_position = last_exit_position
	anim.play("Fade_to_level")

########### BYT RUM UNDEGROUND ############
func _enter_new_room(target_scene: String) -> void:
	var error = get_tree().change_scene_to_file(target_scene)
	if error != OK:
		return
	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if target_spawn_point_name != "":
		var spawn_point = get_tree().current_scene.find_child(target_spawn_point_name)
		if spawn_point:
			player.global_position = spawn_point.global_position
		else:
			push_warning("Hittade inte spawnpunkt:", target_spawn_point_name)
	anim.play("Fade_to_level")
