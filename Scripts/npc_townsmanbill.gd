extends CharacterBody2D

const SPEED = 50

var current_state = IDLE
var is_roaming = true
var is_chatting = false
var dir = Vector2.RIGHT
var start_pos
#var player = get_tree().get_first_node_in_group("player")

enum {IDLE, NEW_DIR, WALK}


func _ready() -> void:
	randomize()
	start_pos = position
	$InteractionArea.interact = Callable(self, "_on_interact")

func _process(delta: float) -> void:
	if current_state == 0 or current_state == 1:
		$AnimatedSprite2D.play("Idle")
	elif current_state == 2 and not is_chatting:
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

func choose(array):
	array.shuffle() #godot funktion
	return array.front()

func _movement(delta):
	if not is_chatting:
		velocity = dir * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO # Stoppa NPC:n om den pratar

func _on_interact():
	is_chatting = true
	is_roaming = false
	$AnimatedSprite2D.play("Idle")
	$Dialogue.start()
	
func _on_timer_timeout() -> void:
	$RoamTimer.wait_time = choose([0.5,1,1.5])
	current_state = choose([IDLE, NEW_DIR, WALK])


func _on_dialogue_dialogue_finished() -> void:
	is_chatting = false
	is_roaming = true
