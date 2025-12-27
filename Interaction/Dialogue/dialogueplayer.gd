extends Control
signal dialogue_finished
@export_file(" ") var dialogue_file

var dialogue = []
var current_dialogue_id = 0
var dialogue_active = false
var dialogue_completed = false

func _ready() -> void:
	$NinePatchRect.visible = false
	$".".show()
func start():
	if dialogue_active or dialogue_completed: #om aktiv, så är vi redan igång med dialog och vi returnar
		return

	$NinePatchRect.visible = true
	dialogue_active = true
	dialogue = _load_dialogue() #vi laddar dialogen som vi vill köra
	current_dialogue_id = -1 
	next_script()
func _load_dialogue():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content #dialogen blir = det vårt innehåll i filen är
	
func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	if dialogue_active == false:
		start()
	else:
		next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue): #dialog avslutas
		dialogue_active = false
		dialogue_completed = true
		$NinePatchRect.visible = false
		emit_signal("dialogue_finished")
		return
		
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text']
