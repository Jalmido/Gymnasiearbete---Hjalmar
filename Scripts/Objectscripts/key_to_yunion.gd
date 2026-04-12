extends Area2D


func _on_body_entered(body: Node2D) -> void:
	"
	När man kolliderar med nyckelns area ändras Global varen till true och nyckeln läggs till i hotbaren.
	"
	if body.is_in_group("player"):
		Globals.yunion_key_collected = true
		queue_free()
		
