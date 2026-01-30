extends CharacterBody2D

const MAX_SPEED = 200.0
const ACC = 1500.0
const SWIM_FORCE = -100.0 
const GRAVITY = 400.0      
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
const SWIM_ACCEL = -600.0  # Kraften när man håller inne space
const MAX_SWIM_SPEED = -300.0 # Maxhastighet uppåt så man inte flyger iväg

enum { IDLE, WALK, SWIM , DASH, DEAD}
var state = WALK
var direction_name = "right" 
var attacking = false
var current_item: String = "None"
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var can_take_damage = true
var can_dash = true
var cooldown_duration = 2


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cooldown_timer: Timer = $DashCooldownTimer
@onready var progressbar: ProgressBar = $HUD/ProgressBar



func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		SWIM:
			_swim_state(delta)
		DASH:
			_dash_state(delta)
		DEAD:
			_dead_state(delta)
			
func _process(delta: float) -> void:
	_update_dash_bar()


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

	move_and_slide()

func _update_direction(axis: float) -> void:
	if axis > 0:
		direction_name = "right"
	elif axis < 0:
		direction_name = "left"


func _change_hotbar_item(item_name: String) -> void:
	$Handgun.disable_weapon()

	
	# Aktivera det valda vapnet
	if item_name == "Pistol":
		$Handgun.enable_weapon()
		attacking = false
	elif item_name == "Sword":
		current_item = "Sword"
		attacking = true
	elif item_name == "Health_Potion":
		current_item = "Health_Potion"
		attacking = false
 
func _drink_potion() -> void:
	
	if Globals.health_potions_in_inv > 0 and Globals.lives < 4:
		Globals.lives += 1
		Globals.health_potions_in_inv -= 1
		print("SKÅL!")

func _take_damage(amount: int) -> void:
	if not can_take_damage:
		return
	
	if can_take_damage:
		can_take_damage = false
		$DamageCooldownTimer.start()
		Globals.lives -= amount

		if Globals.lives <= 0:
			_enter_dead_state()

func _start_dash_cooldown():
	progressbar.value = 0.0
	cooldown_timer.start(cooldown_duration) 

func _update_dash_bar():
	if not can_dash:
		var time_passed = cooldown_timer.wait_time - cooldown_timer.time_left
		progressbar.value = time_passed
	else:
		progressbar.value = cooldown_duration
# ------------------------------
# State logik
# ------------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shift"):
		_enter_dash_state()

func _idle_state(delta: float) -> void:
	anim.play("Idle_" + direction_name)

	_movement(delta, 0)
	
	var axis = Input.get_axis("Left", "Right")
	if axis != 0 and is_on_floor():
		_enter_walk_state()
	
	if Input.is_action_just_pressed("Jump"):
		_enter_swim_state() # Nu ger denna fart uppåt!

func _walk_state(delta: float) -> void:
	anim.play("Swim_" + direction_name)

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

	var is_swimming_up = Input.is_action_pressed("Jump")

	if is_swimming_up:
		velocity.y = move_toward(velocity.y, MAX_SWIM_SPEED, abs(SWIM_ACCEL) * delta)

	# Vi skickar med 'not is_swimming_up' som apply_gravity. 
	# Om vi simmar uppåt (true), blir apply_gravity = false.
	_movement(delta, axis, not is_swimming_up)
	
	if is_on_floor() and velocity.y >= 0:
		if axis == 0: _enter_idle_state()
		else: _enter_walk_state()

func _dash_state(delta: float) -> void:
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED
	
	# VIKTIGT: Du måste flytta gubben!
	move_and_slide() 
	
	if dash_timer <= 0:
		state = SWIM if not is_on_floor() else IDLE

func _dead_state(delta: float) -> void:
	#queue_free()
	pass
# ------------------------------
# Enter state funktioner
# ------------------------------

func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK

func _enter_swim_state():
	state = SWIM
	velocity.y = SWIM_FORCE

func _enter_dash_state():
	if state == DASH or not can_dash: 
		return
	
	state = DASH
	dash_timer = DASH_DURATION
	
	# Bestäm riktning baserat på senaste håll man rörde sig
	var axis = Input.get_axis("Left", "Right")
	if axis != 0:
		dash_direction = Vector2(axis, 0)
	else:
		# Om man står stilla, dasha åt det håll man tittar
		dash_direction = Vector2(1, 0) if direction_name == "right" else Vector2(-1, 0)
	anim.play("Dash_" + direction_name)
	can_dash = false
	_start_dash_cooldown()
func _enter_dead_state():
	state = DEAD

func _on_dash_area_body_entered(body: Node2D) -> void:
	if state == DASH:
		print("träffad med dash")
		body._take_damage()


func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
