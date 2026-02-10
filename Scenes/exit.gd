extends Node2D


func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().change_scene_to_file("res://Scenes/Cutscenes/enter_yunion_cutscene.tscn")
