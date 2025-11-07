extends CharacterBody2D
class_name Player

const MAX_SPEED = 160
const ACC = 1100

enum { IDLE, WALK, DEAD }
var state = IDLE
var direction_name = "down"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			#_dead_state(delta)
			pass
# ------------------------------
# Movement helper
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC * delta)
	move_and_slide()

func _update_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			direction_name = "right"
		
		else:
			direction_name = "left"
	
	else:
		if direction.y > 0:
			direction_name = "down"
		else:
			direction_name = "up"

# ------------------------------
# State functions
# ------------------------------
func _idle_state(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	if input_vector != Vector2.ZERO:
		_enter_walk_state()
	else:
		anim.play("Idle_" + direction_name)
	
	
	_movement(delta, Vector2.ZERO)

func _walk_state(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	if input_vector == Vector2.ZERO:
		_enter_idle_state()
	else:
		_update_direction(input_vector)
		anim.play("Walk_" + direction_name)
		
	_update_direction(input_vector)
	_movement(delta, input_vector)
"""
func _dead_state(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
"""
# ----------------------
#Animation funktion
# ----------------------

func _Enter_underground():
	AnimPlayer.play("Enter_underground")



# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	state = IDLE


func _enter_walk_state():
	state = WALK

"
func _enter_dead_state():
	state = DEAD

"
