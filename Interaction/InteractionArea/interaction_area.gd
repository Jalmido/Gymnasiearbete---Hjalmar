extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"

var interact: Callable = func(): #en callable är en variabletyp som innehåller en funktion, som kan bestämmas utifrån situation
	pass


func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self) 


func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
