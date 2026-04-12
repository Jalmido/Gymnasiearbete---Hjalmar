extends CanvasLayer

func _ready() -> void:
	"
	Gömmer den som default
	"
	hide()

func _input(event: InputEvent) -> void:
	"
	Om man trycker escape anropas _toggle_pause() och menyn dyker upp/försvinner
	"
	if event.is_action_pressed("Pause"): 
		_toggle_pause()

func _toggle_pause():
	"
	Om pause är aktiv, så blir den inte aktiv och vice versa. 
	Om den blir synlig så blurras bakgrunden med en nice shader!
	"
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	if visible:
		
		var tween = create_tween()
		#Fräsig blur shader vid paus
		tween.tween_property($BlurBackground.material, "shader_parameter/blur_amount", 2.5, 0.3).from(0.0)
	
### SIgnals

func _on_resume_button_pressed():
	"
	Om man trycker på resume knappen, så stängs menyn
	"
	_toggle_pause()

func _on_restart_button_pressed():
	"
	Menyn stängs, nuvarande scenen startas om och checkpoint loadas.
	"
	_toggle_pause()
	get_tree().reload_current_scene()
	Globals.load_checkpoint()

func _on_quit_button_pressed():
	"
	Om man trycker på quit knappen, avslutas spelet
	"
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void: #
	"
	Master volume bar i menyn
	"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))



	


func _on_toggle_fullscreen_toggled(toggled_on: bool) -> void: #fullscreen eller windowed
	"
	Togglar fullscreen om man togglar toggeln :P (ändrar mellan windowed och fullscreen)
	"
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
