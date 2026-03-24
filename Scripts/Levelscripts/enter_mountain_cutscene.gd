extends Node2D



func _ready() -> void:
	$AnimationPlayer.play("Cutscene")
	$PlayerInCutscene/AnimatedSprite2D.play("Walk_up")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	LocationManager._play_animation()
	$Timer.start()



func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/mountain_village.tscn")
	LocationManager._play_animation2()
