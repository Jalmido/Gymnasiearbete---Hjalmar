extends Node2D



func _on_area_2d_body_entered(_body: Node2D) -> void:
	LocationManager._play_animation()
	$ExitHouseTimer.start()

func _on_exit_house_timer_timeout() -> void:
	LocationManager._exit_house()
