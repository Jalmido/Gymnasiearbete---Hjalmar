extends Node2D

@onready var player: Player = $Player

var first_time_entering_scene = true

func _ready() -> void:
	Globals.save_checkpoint()
	var scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path not in Globals.visited_scenes: #kolla om animationen ska köras
		Globals.visited_scenes.append(scene_path)
		$Player.set_physics_process(false)
		$Opening_Cutscene/Cutscene_Camera.make_current()
		$Opening_Cutscene/AnimationPlayer.play("Opening_Cutscene")

		first_time_entering_scene = false
	
	if LocationManager.last_exit_position:
		player.global_position = LocationManager.last_exit_position
	else:
		pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$Player/Camera2D.make_current()
	$Popup_UI.show()
	$Player.set_physics_process(true)
