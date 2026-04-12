extends Node2D


### Denna används också bara en gång. Dåligt gjord. En av de första grejerna jag gjorde också, så skyller på det.


@onready var change_to_underground: InteractionArea = $Change_to_underground


func _ready() -> void:
	"
	Callable definieras som _on_interact
	"
	change_to_underground.interact = Callable(self, "_on_interact")


func _on_interact():
	"
	Om man interagerar och har fått sin objective av gubben, så spelas hopp animationen och changeleveltimer startar.
	"
	if Globals.objective_recieved: #måste prata m Soren först
		var player = get_tree().get_first_node_in_group("player")
		LocationManager.last_exit_position = player.global_position
		player._Enter_underground()
		$ChangeLevelTimer.start()


func _on_change_level_timer_timeout() -> void:
	"
	När changeleveltimer är klar, byts scen till underground
	"
	get_tree().change_scene_to_file("res://Scenes/Underground/underground_room_1.tscn")
