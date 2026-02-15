extends Node2D



@export var level_music: AudioStream

func _ready() -> void:
	MusicManager.play_track(level_music)
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	LocationManager._play_animation()
	$ExitHouseTimer.start()

func _on_exit_house_timer_timeout() -> void:
	LocationManager._exit_house()
