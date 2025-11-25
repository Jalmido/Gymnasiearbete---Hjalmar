extends CharacterBody2D
class_name Player

const MAX_SPEED = 160
const MAX_JUMP_DISTANCE = 50
const ACC = 1100

enum { IDLE, WALK, DEAD, JUMP }
var state = IDLE
var direction_name = "down"
var can_take_damage = true
var jump_direction: Vector2 = Vector2.ZERO
var jump_start_pos: Vector2
var jump_speed = 200

@onready var JumpRaycast: RayCast2D = $JumpRayCast
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var DamageCooldownTimer: Timer = $DamageCooldownTimer

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
		JUMP:
			_jump_state(delta)
# ------------------------------
# Movement helper
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC * delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump"):
		_enter_jump_state()

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

func _take_damage() -> void:
	if not can_take_damage:
		return
	
	if can_take_damage:
		can_take_damage = false
		DamageCooldownTimer.start()
		Globals.lives -= 1

		if Globals.lives <= 0:
			_enter_dead_state()

func _display_raycast() -> void:
	JumpRaycast.show()
	var tween = create_tween()
	tween.set_loops()
	var rotate_raycast = tween.tween_property(JumpRaycast, "rotation", 2*PI, 1.0).as_relative() #Roterar, och as_relative är inbyggd funktion som gör att den fortsätter där den slutade

	

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

func _dead_state(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	
	
	#game over skärm görs sen

func _jump_state(delta: float) -> void:
	AnimPlayer.play("Jump")
	move_and_slide()
	var traveled_jump_distance = global_position.distance_to(jump_start_pos)
	if traveled_jump_distance >= MAX_JUMP_DISTANCE:
		velocity = Vector2.ZERO
		_enter_idle_state()

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


func _enter_dead_state():
	state = DEAD

func _enter_jump_state():
	state = JUMP
	jump_start_pos = global_position
	jump_direction = Vector2.DOWN.rotated(JumpRaycast.global_rotation).normalized()
	velocity = jump_direction * jump_speed
########## SIGNALS ########

func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true
