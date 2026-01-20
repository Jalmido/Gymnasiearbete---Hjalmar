extends CharacterBody2D

const MAX_SPEED = 200.0
const ACC = 1500.0
const SWIM_FORCE = -200.0 
const GRAVITY = 400.0      

enum { IDLE, WALK, SWIM }
var state = IDLE
var direction_name = "right" 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		SWIM:
			_swim_state(delta)
	
	move_and_slide()

# ------------------------------
# Central rörelsefunktion
# ------------------------------

func _movement(delta: float, input_x: float, apply_gravity: bool = true) -> void:
	# Horisontell rörelse (Gå eller bromsa)
	if input_x != 0:
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, ACC * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACC * delta)
	
	# Gravitation (Sjunk)
	if apply_gravity and not is_on_floor():
		velocity.y += GRAVITY * delta


func _update_direction(axis: float) -> void:
	if axis > 0:
		direction_name = "right"
	elif axis < 0:
		direction_name = "left"


# ------------------------------
# State logik
# ------------------------------
# ... (behåll konstanter och variabler överst)

# ------------------------------
# State logik
# ------------------------------

func _idle_state(delta: float) -> void:
	anim.play("Idle_" + direction_name)

	_movement(delta, 0)
	
	var axis = Input.get_axis("Left", "Right")
	if axis != 0 and is_on_floor():
		_enter_walk_state()
	
	if Input.is_action_just_pressed("Jump"):
		_enter_swim_state() # Nu ger denna fart uppåt!

func _walk_state(delta: float) -> void:
	anim.play("Walk_" + direction_name)

	var axis = Input.get_axis("Left", "Right")
	
	if axis == 0:
		_enter_idle_state()
	else:
		_update_direction(axis)
		_movement(delta, axis)
	
	if not is_on_floor():
		state = SWIM 
		
	if Input.is_action_just_pressed("Jump"):
		_enter_swim_state()

func _swim_state(delta: float) -> void:
	anim.play("Swim_" + direction_name) 
	
	var axis = Input.get_axis("Left", "Right")
	_update_direction(axis)
	

	_movement(delta, axis)
	
	# Fixat stavfel: "jump" istället för "Jump"
	if Input.is_action_just_pressed("Jump"):
		velocity.y = SWIM_FORCE
	
	if is_on_floor():
		_enter_idle_state()

# ... (behåll hjälpfunktioner)

# ------------------------------
# Enter state funktioner
# ------------------------------

func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK

func _enter_swim_state():
	state = SWIM
	# VIKTIGT: Detta gör att "hoppet" från marken faktiskt sker
	velocity.y = SWIM_FORCE
