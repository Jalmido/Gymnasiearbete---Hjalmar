extends CanvasLayer


@export_multiline var popup_text: String = "meddelande..."

func _ready() -> void:
	$NinePatchRect/VBoxContainer/Label.text = popup_text



func _on_close_button_pressed() -> void:
	hide()
