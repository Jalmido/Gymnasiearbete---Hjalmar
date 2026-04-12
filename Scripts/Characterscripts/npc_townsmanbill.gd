extends CharacterBody2D

const SPEED = 50

var current_state = IDLE
var is_roaming = true
var is_chatting = false
var dir = Vector2.RIGHT

#var player = get_tree().get_first_node_in_group("player")

enum {IDLE, NEW_DIR, WALK}


func _ready() -> void:
	"
	Callable funktionen från interaction arean definieras som _on_interact
	"
	
	$InteractionArea.interact = Callable(self, "_on_interact")

func _process(delta: float) -> void:
	"
	NPC:ns state machine. Sköter animationer om han idlar. Om staten är NEW_DIR slumpas en riktning,
	som han sedan går i via update_direction och movement
	"
	if current_state == IDLE or current_state == NEW_DIR:
		$AnimatedSprite2D.play("Idle")
	elif current_state == WALK and not is_chatting:
		_update_direction(dir)
		
	
	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]) #randomizar mellan vilken riktning den ska gå
			WALK:
				_movement(delta)

		
		
func _update_direction(direction: Vector2):
	"
	Animationer körs utifrån vilken riktning han går i.
	"
	if dir.x == -1: #går vänster
		$AnimatedSprite2D.play("Walk_left")
		$AnimatedSprite2D.flip_h = false
	if dir.x == 1: #går hgöer
		$AnimatedSprite2D.play("Walk_left")
		$AnimatedSprite2D.flip_h = true
	if dir.y == -1: #går upp
		$AnimatedSprite2D.play("Walk_up")
		$AnimatedSprite2D.flip_h = false
	if dir.y == 1: #går ner
		$AnimatedSprite2D.play("Walk_down")
		$AnimatedSprite2D.flip_h = false

func choose(array): #Hade kunnat använda .pick_random funnktionen som ingår i godot, men visste inte att den fanns... 
	"
	Blandar om en lista och returnerar blandad lista.
	"
	array.shuffle() #godot funktion
	return array.front()

func _movement(delta):
	"
	Om han inte pratar, så går han runt i en riktning som slumpas när state blir NEW_DIR.
	"
	if not is_chatting:
		velocity = dir * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
func _on_interact():
	"
	När man interagerar, så körs dialogen och han slutar gå.
	"
	is_chatting = true
	is_roaming = false
	$AnimatedSprite2D.play("Idle")
	$Dialogue.start()
	
func _on_timer_timeout() -> void:
	"
	När timern är slut, så slumpas en ny state och en ny wait_time på roam_timern.
	"
	$RoamTimer.wait_time = choose([0.5,1,1.5])
	current_state = choose([IDLE, NEW_DIR, WALK])


func _on_dialogue_dialogue_finished() -> void:
	"
	När dialogen är klar börjar han gå igen.
	"
	is_chatting = false
	is_roaming = true
