extends Node

@onready var music_player = $AudioStreamPlayer

func play_track(stream: AudioStream):
	if music_player.stream == stream:
		return # Spela inte om den redan körs!
	
	music_player.stream = stream
	music_player.play()
