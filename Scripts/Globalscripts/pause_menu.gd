extends CanvasLayer

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"): 
		_toggle_pause()

func _toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	if visible:
		
		var tween = create_tween()
		#Fräsig blur shader vid paus
		tween.tween_property($BlurBackground.material, "shader_parameter/blur_amount", 2.5, 0.3).from(0.0)
	
### SIgnals

func _on_resume_button_pressed():
	_toggle_pause()

func _on_restart_button_pressed():
	_toggle_pause()
	get_tree().reload_current_scene()
	Globals.load_checkpoint()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))
