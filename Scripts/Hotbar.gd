extends Control

@onready var grid = $GridContainer

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			select_slot(index)

func select_slot(index: int):
	if index < grid.get_child_count(): #ser så vi inte trycker på knapp som int finns

		for child in grid.get_children():
			var tween_down = create_tween()
			tween_down.tween_property(child, "position:y", 0.0, 0.1) 

		var button = grid.get_child(index) as ItemButton 
		if button:
			button.button_pressed = true #
		
			var tween_up = create_tween()
			tween_up.tween_property(button, "position:y", -20.0, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			

			var player = get_tree().get_first_node_in_group("player")
			player._change_hotbar_item(button.item_name)
