extends CharacterBody2D

var start_boss_fight = false

func _ready() -> void:
	var current_scene:String = get_tree().current_scene.scene_file_path
	print(current_scene)
	if current_scene == "res://Scenes/Yunion/the_yunion.tscn":
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue2.json"
	else:
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue1.json"

func _process(delta: float) -> void:
	if start_boss_fight:
		print("startar bossifght")
		$"../AudioStreamPlayer2D".play()
