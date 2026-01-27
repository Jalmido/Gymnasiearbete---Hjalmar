extends Node2D
 
var boss_alive = true

func _on_fight_activation_area_body_entered(body: Node2D) -> void:
	if boss_alive:
		$Boss_Arena_doors.enabled = true	
		$Executioner_boss.active = true
