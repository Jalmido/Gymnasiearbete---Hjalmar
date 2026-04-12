extends CanvasLayer

@onready var healthbar: TextureRect = $Healthbarimage
@onready var ammolabel: RichTextLabel = $AmmoLabel


func _ready() -> void:
	"
	När Global.lives ändras skickas en signal som kopplas här, vilket anropar _update healthbar_image
	"
	Globals.lives_changed.connect(_update_healthbar_image)
	_update_healthbar_image(Globals.lives)


func _process(_delta: float) -> void:
	"
	Ammo texten uppdateras för att visa hur mycket ammo man har i magget respektive inventoryt.
	"
	ammolabel.text = str(Globals.ammo_in_mag) + " / " + str(Globals.ammo_in_inv)

func _update_healthbar_image(new_lives) -> void:
	"
	Hotbar bilden förändras beroende på hur mycket hp man har.
	"
	match new_lives:
		4: 
			healthbar.texture = preload("res://Assets/ui/Healthbar/06-ezgif.com-crop.png")
		3: 
			healthbar.texture = preload("res://Assets/ui/Healthbar/06-ezgif.com-crop-2.png")
		2: 
			healthbar.texture = preload("res://Assets/ui/Healthbar/06-ezgif.com-crop-3.png")
		1: 
			healthbar.texture = preload("res://Assets/ui/Healthbar/06-ezgif.com-crop-4.png")
		0: 
			healthbar.texture = preload("res://Assets/ui/Healthbar/06-ezgif.com-crop-5.png")
