extends Node2D

@export var level_music: AudioStream

func _ready() -> void:
	$AnimationPlayer.play("Walk_to_door")
	MusicManager.play_track(level_music)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:

	get_tree().change_scene_to_file("res://Scenes/Yunion/the_yunion.tscn")
