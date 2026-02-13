extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.yunion_key_collected = true
		queue_free()
		
