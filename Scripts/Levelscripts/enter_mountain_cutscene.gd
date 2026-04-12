extends Node2D



func _ready() -> void:
	"
	Cutscene startas, och cutsceneplayerns animation walk_up spelas
	"
	$AnimationPlayer.play("Cutscene")
	$PlayerInCutscene/AnimatedSprite2D.play("Walk_up")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	"
	När cutscenen är klar, startas fade to black animationen i LocationManager och en changeleveltimer startar
	"
	LocationManager._play_animation()
	$Timer.start()



func _on_timer_timeout() -> void:
	"
	När changeleveltimern är klar byts scen till mountain village.
	"
	get_tree().change_scene_to_file("res://Scenes/Levels/mountain_village.tscn")
	LocationManager._play_animation2()
