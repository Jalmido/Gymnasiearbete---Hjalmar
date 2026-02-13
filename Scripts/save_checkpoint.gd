extends Node2D

"""
DETTA SCRIPT ANVÄNDS TILL LEVELS SOM INTE HAR NÅGOT ÖVRIGT SCRIPT
FÖR ATT SPARA ETT CHECKPOINT ISH
"""

func _ready() -> void:
	Globals.save_checkpoint()
