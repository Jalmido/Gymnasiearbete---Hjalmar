extends Node2D

"""
DETTA SCRIPT ANVÄNDS TILL LEVELS SOM INTE HAR NÅGOT ÖVRIGT SCRIPT
FÖR ATT SPARA ETT CHECKPOINT ISH

ANVÄNDS OCKSÅ FÖR ATT LADDA SCENENS MUSIC

"""

@export var level_music: AudioStream



func _ready() -> void:
	"
	Sparar checkpoint och skickar in export variabeln level_music till MusicManager
	"
	Globals.save_checkpoint()
	
	if level_music:
		MusicManager.play_track(level_music)
		
