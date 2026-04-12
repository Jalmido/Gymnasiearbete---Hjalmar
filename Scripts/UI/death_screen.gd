extends CanvasLayer



func _on_retry_button_pressed() -> void:
	"
	Om man trycker på retry knappen, så reloadar scenen och checkpointen loadar. 
	"
	Globals.load_checkpoint()
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_quit_button_pressed() -> void:
	"
	Trycker man på quit, så avslutas spelet
	"
	get_tree().quit()
