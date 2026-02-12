extends Node2D

@onready var ammo = get_node_or_null("Ammo")
@onready var health_potion = get_node_or_null("HealthPotion")


func _ready() -> void:
	if ammo:

		if ammo.item_id in Globals.picked_up_items:
			ammo.queue_free()
	if health_potion:
		if health_potion.item_id in Globals.picked_up_items:
			health_potion.queue_free()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	LocationManager._play_animation()
	$ExitHouseTimer.start()

func _on_exit_house_timer_timeout() -> void:
	LocationManager._exit_house()
