extends Node2D

@onready var player: Player = $Player

var first_time_entering_scene = true

func _ready() -> void:
	"
	Checkpoint sparas och musik startas. Om det är första gången man kör denna scen, så körs en cutscene
	Ens global_position ändras också beroende på om det är första gången du startar eller om du kommer ut ur ett hus.
	"
	Globals.save_checkpoint()
	MusicManager.play_track(preload("res://Audio/Music/1-10 Skyloft.mp3"))
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
	"
	När cutscenen är klar kommer en popup upp och man kan röra sig.
	"
	$Player/Camera2D.make_current()
	$Popup_UI.show()
	$Player.set_physics_process(true)
