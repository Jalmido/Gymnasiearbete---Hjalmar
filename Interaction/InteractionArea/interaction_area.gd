extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"

var interact: Callable = func(): #en callable är en variabletyp som innehåller en funktion, som kan bestämmas utifrån situation
	pass


func _on_body_entered(body: Node2D) -> void:
	"
	När man går in i interaction_arean läggs den in som parameter i InteractionManagerns script register_area
	"
	if body.is_in_group("player"):
		InteractionManager.register_area(self) 


func _on_body_exited(body: Node2D) -> void:
	"
	När man går ut ur interaction_arean läggs den in som parameter i InteractionManagerns script unregister_area
	"
	if body.is_in_group("player"):
		InteractionManager.unregister_area(self)
