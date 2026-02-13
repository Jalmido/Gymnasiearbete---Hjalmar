extends CanvasLayer


func _ready() -> void:
	get_node("PanelContainer/VBoxContainer/Retry_button").grab_focus()
	

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	Globals.load_checkpoint()

	

func _on_quit_button_pressed() -> void:
	get_tree().quit()
