extends Node

@onready var music_player = $AudioStreamPlayer

func play_track(stream: AudioStream):
	if music_player.stream == stream:
		return #Starta inte musik om samma låt redan körs. Ger musik som kan fortsätta mellan scenerr
	
	music_player.stream = stream
	music_player.play()
