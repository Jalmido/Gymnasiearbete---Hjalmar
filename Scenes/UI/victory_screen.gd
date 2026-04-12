extends CanvasLayer

"""
Denna Scen och script är globals, och väntar på signalen från bossar som dör.
Signalen skickas när boss fight mode är på, alltså inte story mode, då visas victory skärm när bossen dör. 
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"
	Per automatik är denna gömd, och signal kopplas från Globals.victory_screen_requested, som kopplar till funktionen _on_victory
	"
	hide()
	Globals.victory_screen_requested.connect(_on_victory)

func _on_victory(): #När man vinner triggas victory skärmen och man kan gå tillbaka t menyn. 
	show()
	get_tree().paused = true


func _on_return_button_pressed() -> void:
	"
	Trycker man på return återvänder man till start menyn
	"
	get_tree().change_scene_to_file("res://Scenes/UI/start_menu.tscn")
	hide()
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	"
	Trycker man på quit avslutas spelet
	"
	get_tree().quit()
	
