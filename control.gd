extends Control


func _ready() -> void:
	get_node("VBoxContainer/Start_button").grab_focus()
	$AnimatedSprite2D.play("Idle")
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
