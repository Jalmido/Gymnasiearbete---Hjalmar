extends Control

@onready var grid = $GridContainer

func _ready() -> void:
	"
	Varje knapps (som är barn till gridcontainern) pressed signal kopplas till select_slot funktionen.
	Så när man trycker på en knapp, så körs select_slot med den knappens index. 
	"
	for i in grid.get_child_count():
		var button = grid.get_child(i)
		#Koppla knappen t rätt index
		button.pressed.connect(select_slot.bind(i))

func _input(event: InputEvent) -> void:
	"
	Lyssnar efter att man tryckt ner knanppar 1-9 på tangentbordet, å beräknar ut deras index
	så att select_slot får in rätt index. (ex tangent 1 blir index 0, vilket är rätt, då svärd knappen har index 0 för det är den första barn noden
	"
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			select_slot(index)

func select_slot(index: int):
	"
	Anropar _change_hotbar_item i playern med den valda knappens item_name (som är en export var sträng)
	Hanterar även det visuella när man väljer item i hotbaren mha tweens, som ändrar deras y värde så att knappen åker upp 20 pixlar på 0.1 sek, med en ease.
	"
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
