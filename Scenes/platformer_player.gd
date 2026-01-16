extends CharacterBody2D

# Konstanter för plattformsfysik
const MAX_SPEED = 200.0
const ACC = 1500.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 900.0

enum { IDLE, WALK, SWIM }
var state = IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# Kör logiken för det nuvarande tillståndet
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		SWIM:
			_swim_state(delta)
	


	move_and_slide()

# ------------------------------
# State logik
# ------------------------------

func _idle_state(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	
	# Bromsa ner
	velocity.x = move_toward(velocity.x, 0, ACC * delta)
	
	if input_x != 0:
		_enter_walk_state()
	
	if Input.is_action_just_pressed("jump"):
		_enter_swim_state()

func _walk_state(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	
	if input_x == 0:
		_enter_idle_state()
	else:
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, ACC * delta)
		_update_direction(input_x)
	
	if Input.is_action_just_pressed("jump"):
		_enter_swim_state()

func _swim_state(delta: float) -> void:
	# Enkel luftkontroll
	var input_x = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, ACC * delta)
	_update_direction(input_x)
	
	# Applicera gravitation
	velocity.y += GRAVITY * delta
	
	# Landa
	if is_on_floor():
		if velocity.x == 0:
			_enter_idle_state()
		else:
			_enter_walk_state()

# ------------------------------
# Hjälpfunktioner
# ------------------------------

func _update_direction(input_x: float) -> void:
	if input_x > 0:
		sprite.flip_h = false
	elif input_x < 0:
		sprite.flip_h = true

# ------------------------------
# Enter state funktioner
# ------------------------------

func _enter_idle_state():
	state = IDLE
	anim.play("Idle")

func _enter_walk_state():
	state = WALK
	anim.play("Walk")

func _enter_swim_state():
	state = SWIM
