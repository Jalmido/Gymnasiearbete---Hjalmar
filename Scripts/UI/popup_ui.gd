extends CanvasLayer


@export_multiline var popup_text: String = "meddelande..."

func _ready() -> void:
	"
	Texten på labeln ändras enligt export varen popup_text
	"
	$NinePatchRect/VBoxContainer/Label.text = popup_text



func _on_close_button_pressed() -> void:
	"
	När man trycker på close knappen försvinner popupen.
	"
	hide()
