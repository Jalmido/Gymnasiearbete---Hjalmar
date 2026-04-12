extends Area2D

"""
Gammal grej som används på ett ställe. Lite onödigt och finns bättre lösningar
"""

@export var tilemap_path: NodePath
@onready var tilemap: TileMapLayer = $"../Tilemaplayers/Elevation"

func _on_body_entered(body: Node2D) -> void:
	"
	Om man går in i arean så stängs tilemapens collision av och man kan gå genom (gå upp på upphöjnaden i overworld)
	"
	if body.name == "Player":
		tilemap.collision_enabled = false
		body.z_index = 2


func _on_body_exited(body: Node2D) -> void:
	"
	När man går ut ur arean, slås collisionen för tilemapen på igen. 
	"
	if body.name == "Player":
		tilemap.collision_enabled = true
