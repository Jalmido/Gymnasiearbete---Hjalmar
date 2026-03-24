extends Area2D
class_name JumpArea


@onready var player = get_tree().get_first_node_in_group("player")
@onready var tilemap: TileMapLayer = $"../Tilemaplayers/Ground"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.can_jump = true
		player._display_raycast()



func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.can_jump = false
		player._reset_raycast()
		
