extends Node

@onready var music_player = $AudioStreamPlayer

func play_track(stream: AudioStream):
	"
	Bakgrundsmusik som spelas över scener. stream parametern är en AudioStream, som är en export var för varje level scen.
	Alltså, varje level har en export var med en ljudfil som bakgrundsmusik, som matas in här 
	Osså om två scener i rad har samma musik, så fortsätter musiken bara spelas, så man får en smooth övergång.
	"
	if music_player.stream == stream:
		return #Starta inte musik om samma låt redan körs. Ger musik som kan fortsätta mellan scenerr
	
	music_player.stream = stream
	music_player.play()
