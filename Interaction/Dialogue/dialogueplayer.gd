extends Control
signal dialogue_finished
@export_file(" ") var dialogue_file

var dialogue = []
var current_dialogue_id = 0
var dialogue_active = false
var dialogue_completed = false

func _ready() -> void:
	"
	dialogrutan döljs
	"
	$NinePatchRect.visible = false
	$".".show()
	
func start():
	"
	Aktiverar dialogsystemet när man interactar med en NPC. Dialogfilen laddas in,
	dialogrutan laddas in och indexet återställs så dialogen börjar från början. 
	"
	if dialogue_active or dialogue_completed: #om aktiv, så är vi redan igång med dialog och vi returnar
		return

	$NinePatchRect.visible = true
	dialogue_active = true
	dialogue = _load_dialogue() #vi laddar dialogen som vi vill köra
	current_dialogue_id = -1 
	next_script()
	
func _load_dialogue():
	"
	Öppnar och läser in dialogfilen å gör om innehållet till en läsbar dictionary av ord å namn som
	koden kan arbeta med
	"
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text()) #Gör om textfilen från att bara egentligen vara massa text, till tolkningsbara dictionaries
	return content #dialogen blir = det vårt innehåll i filen är
	
func _input(event: InputEvent) -> void:
	"
	När man trycker E (interact) anropas next_script() funktionen, om dialogen är aktiv, annars startar den.
	"
	if not event.is_action_pressed("interact"):
		return
	
	if dialogue_active == false:
		start()
	else:
		next_script()

func next_script():
	"
	Byter till nästa rad i dialog filen och uppdaterar name och text labeln på ninepatchrecten beroende på vilken rad vi är i dialogscriptet. 
	När dialogen är klar döljs dialogrutan igen. Specialfall om dialogen är ElderSorens andra, då start_boss_fight sätts till true hos honom isåfall.
	"
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue): #eftersom att dialogue numera bara är en array med massa dictionaries, så är len alltså mängden dictionaries (alltså mängden rader i arrayen).
		dialogue_active = false
		dialogue_completed = true
		$NinePatchRect.visible = false
		if dialogue_file == "res://Interaction/Dialogue/ElderSoren_dialogue2.json":
			$"..".start_boss_fight = true

		emit_signal("dialogue_finished")
		return
		
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name'] #tar ut värdet som tillhör name nyckeln och stoppar in den som texten på name labeln från vår nuvarande rad i dialogen
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text'] #tar ut värdet som tillhör text nyckeln och stoppar in som text labelns text.
