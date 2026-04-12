extends Node2D

@export var level_music: AudioStream

func _ready() -> void:
	"
	Cutscenen körs, och bakgrundsmusiken definieras via export variabel
	"
	$AnimationPlayer.play("Walk_to_door")
	MusicManager.play_track(level_music)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	"
	När animationen är klar byts scenen till the yunion, och nyckeln försvinner ur inventoryt.
	"
	get_tree().change_scene_to_file("res://Scenes/Yunion/the_yunion.tscn")
	Globals.yunion_key_collected = false #så att den försvinner ur inventory igen
