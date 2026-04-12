extends Node2D


@export_file(" ") var target_scene
@export var level_music: AudioStream

func _ready() -> void:
	"
	level musiken körs, och definieras som export variabel för varje separat interiör.
	"
	MusicManager.play_track(level_music)
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	"
	När man går in i arean, fadear det till svart och startar exithousetimer
	"
	LocationManager._play_animation()
	$ExitHouseTimer.start()

func _on_exit_house_timer_timeout() -> void:
	"
	När exithousetimer är klar, byts scen till respektive interiörs target scene (export var)
	"
	LocationManager._exit_house(target_scene)
