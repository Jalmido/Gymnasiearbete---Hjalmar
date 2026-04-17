extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

var last_exit_position: Vector2
var last_jump_position: Vector2
var target_spawn_point_name: String = ""


func _play_animation() -> void:
	"
	För att fadea till svart när man övergår mellan scener
	"
	anim.play("Fade_to_black")

func _play_animation2() -> void:
	"
	För att fadea till leveln när man övergår mellan scener
	"
	anim.play("Fade_to_level")
	
########## IN I HUS ############

func enter_house(house_number: int) -> void:
	"
	House number är en export var som bestäms för varje separat hus. Det avgör vilken hus-interiörs-scen
	som man byter till. 
	"
	var target_scene = "res://Scenes/Houses/house_%d_interior.tscn" % house_number
	get_tree().change_scene_to_file(target_scene)
	anim.play("Fade_to_level")

########### UT UR HUS ###########
func _exit_house(target_scene: String) -> void:
	"
	Byter scen till target scene som sätts i varje hus-interiör-scen som export variabel. Playerns spawn point 
	är den som sparades när man gick in i huset som last_exit_position. 
	"
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	player.global_position = last_exit_position
	anim.play("Fade_to_level")

########### BYT RUM UNDEGROUND ############
func _enter_new_room(target_scene: String) -> void:
	"
	Byta rum underground till en scen som är en export var från room_change.tscn som den tillhör.
	Anropas från room_change.gd scripts. Target_spawn_point_name är en export var från room_change.tscn
	"
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if target_spawn_point_name != "":
		var spawn_point = get_tree().current_scene.find_child(target_spawn_point_name)
		if spawn_point:
			player.global_position = spawn_point.global_position
	anim.play("Fade_to_level")
