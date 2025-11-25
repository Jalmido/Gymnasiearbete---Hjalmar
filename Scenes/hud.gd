extends CanvasLayer

@onready var healthbar: TextureRect = $HUDcontroller/Healthbarimage

func _ready() -> void:
	Globals.lives_changed.connect(_update_healthbar_image)
	_update_healthbar_image(Globals.lives)

func _update_healthbar_image(new_lives) -> void:
	match new_lives:
		4: 
			healthbar.texture = preload("res://ui/Healthbar/06-ezgif.com-crop.png")
		3: 
			healthbar.texture = preload("res://ui/Healthbar/06-ezgif.com-crop-2.png")
		2: 
			healthbar.texture = preload("res://ui/Healthbar/06-ezgif.com-crop-3.png")
		1: 
			healthbar.texture = preload("res://ui/Healthbar/06-ezgif.com-crop-4.png")
		0: 
			healthbar.texture = preload("res://ui/Healthbar/06-ezgif.com-crop-5.png")
