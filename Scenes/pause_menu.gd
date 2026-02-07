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
		get_node("PanelContainer/VBoxContainer/Resume_button").grab_focus()
	# Om vi visar menyn, se till att musen syns
	if new_pause_state:
		var tween = create_tween()
		# Vi kommer åt shader-parametern via materialet
		tween.tween_property($BlurBackground.material, "shader_parameter/blur_amount", 2.5, 0.3).from(0.0)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Eller vad du använder i spelet

# --- Knapp-funktioner ---

func _on_resume_button_pressed():
	_toggle_pause()

func _on_restart_button_pressed():
	_toggle_pause()
	# Om du inte har checkpoints än, starta om hela scenen:
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()
