extends Node2D
class_name JumpArea

@export var target_position: Vector2
@export var tolerated_timing: float = 0.1

@onready var interaction_area: Area2D = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	player._display_raycast()
