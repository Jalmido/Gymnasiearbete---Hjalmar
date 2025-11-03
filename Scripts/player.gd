extends CharacterBody2D
class_name Player

const MAX_SPEED = 240
const ACC = 1100

enum { IDLE, WALK, DEAD }
var state = IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

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
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true

# ------------------------------
# State functions
# ------------------------------
func _idle_state(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	if input_vector != Vector2.ZERO:
		_enter_walk_state()
		
	
	_update_direction(Vector2.ZERO)
	_movement(delta, Vector2.ZERO)

func _walk_state(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	if input_vector == Vector2.ZERO:
		anim.play("Idle")
	
	if abs(input_vector.x) > abs(input_vector.y):
		# Rörelse horisontellt
		if input_vector.x > 0:
			anim.play("Walk_right")
		else:
			anim.play("Walk_left") #FINNS EJ
	else:
		# Rörelse vertikalt
		if input_vector.y > 0:
			anim.play("Walk_down")
		else:
			anim.play("Walk_up")
	
	_update_direction(input_vector)
	_movement(delta, input_vector)
"""
func _dead_state(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
"""
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	state = IDLE
	anim.play("Idle")

func _enter_walk_state():
	state = WALK


func _enter_dead_state():
	state = DEAD
	anim.play("Dead")
