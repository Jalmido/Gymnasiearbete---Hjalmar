extends Area2D

@export var tilemap_path: NodePath
@onready var tilemap: TileMapLayer = $"../Tilemaplayers/Elevation"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		tilemap.collision_enabled = false
		body.z_index = 2


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		tilemap.collision_enabled = true
