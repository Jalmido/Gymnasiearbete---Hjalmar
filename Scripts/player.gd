extends CharacterBody2D
class_name Player


const MAX_JUMP_DISTANCE = 70
const NORMAL_SPEED = 160
const NORMAL_ACCELERATION = 1100
const ICE_SPEED = 230
const ICE_ACCELERATION = 400

enum { IDLE, WALK, DEAD, JUMP, WATER, ATTACK }

var state = IDLE
var speed: float = NORMAL_SPEED
var acceleration: float = NORMAL_ACCELERATION
var direction_name = "down"
var current_item: String = "None"
var can_take_damage = true
var jump_direction: Vector2 = Vector2.ZERO
var jump_start_pos: Vector2
var jump_speed = 200
var can_jump = false
var attacking = false
var ignore_ground = false
var is_respawning = false

@onready var JumpRaycast: RayCast2D = $JumpRayCast
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var DamageCooldownTimer: Timer = $DamageCooldownTimer
@onready var GroundControlRaycast: RayCast2D = $GroundControlRaycast

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
		WATER:
			_water_state(delta)
		ATTACK:
			_attack_state(delta)
# ------------------------------
# Movement helper
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()

func _update_ground_movement():
	#Normal mark
	speed = NORMAL_SPEED
	acceleration = NORMAL_ACCELERATION
	
	#Se om man är på is
	GroundControlRaycast.enabled = true
	GroundControlRaycast.force_raycast_update()
	if GroundControlRaycast.is_colliding():
		var collider = GroundControlRaycast.get_collider()
		if collider.is_in_group("ice"):
			speed = ICE_SPEED
			acceleration = ICE_ACCELERATION

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump") and can_jump:
		_enter_jump_state()
	if event.is_action_pressed("Attack"):
		if current_item == "Sword" and attacking:
			_enter_attack_state()
		elif current_item == "Health_Potion":
			_drink_potion()
		
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
		DamageCooldownTimer.start()
		Globals.lives -= amount

		if Globals.lives <= 0:
			_enter_dead_state()

func _display_raycast() -> void:
	JumpRaycast.show()
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(JumpRaycast, "rotation", 2*PI, 1.0).as_relative() #Roterar, och as_relative är inbyggd funktion som gör att den fortsätter där den slutade
	
func _reset_raycast() -> void:
	JumpRaycast.hide()
	JumpRaycast.rotation = 0
	JumpRaycast.target_position = Vector2.ZERO

func _landing_manager() -> void:

	velocity = Vector2.ZERO
	set_collision_mask_value(7, true) # Slå på kollision med väggar igen
	
	# Tvinga raycasten att kolla vad som finns under fötterna just nu
	GroundControlRaycast.force_raycast_update()
	
	# Kolla om vi träffade något
	if GroundControlRaycast.is_colliding():
		var collider = GroundControlRaycast.get_collider()
		
		# Kolla om det vi står på är med i gruppen "water"
		if collider.is_in_group("water"):
			_enter_water_state()
			return # VIKTIGT: Avbryt här så vi inte går vidare till idle_state

	# Om det inte var vatten (eller vi missade marken helt), landa som vanligt
	_enter_idle_state()

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
	
	_update_ground_movement() #Kollar om vi är på vanlig mark eller is
	
	if input_vector == Vector2.ZERO:
		_enter_idle_state()
	else:
		_update_direction(input_vector)
		anim.play("Walk_" + direction_name)
		
	_update_direction(input_vector)
	_movement(delta, input_vector)
	
func _dead_state(delta: float) -> void:
	_movement(delta, Vector2.ZERO)

	
	
	#game over skärm görs sen

func _jump_state(_delta: float) -> void:

	AnimPlayer.play("Jump")
	move_and_slide()
	var traveled_jump_distance = global_position.distance_to(jump_start_pos)
	if traveled_jump_distance >= MAX_JUMP_DISTANCE:
		_landing_manager()

func _water_state(_delta: float) -> void:

	velocity = Vector2.ZERO

	if is_respawning:
		return
	is_respawning = true

	AnimPlayer.play("Drowning")
	await AnimPlayer.animation_finished

	# Stoppa animationen så den inte fortsätter behålla scale/modulate
	AnimPlayer.stop()
	AnimPlayer.play("Reset_visual")
	# Respawn position
	global_position = LocationManager.last_jump_position.snapped(Vector2.ONE)

	GroundControlRaycast.enabled = true
	set_collision_mask_value(2, true)

	_take_damage(1)

	is_respawning = false
	_enter_idle_state()

func _attack_state(_delta: float) -> void:
	AnimPlayer.play("Attack_" + direction_name)
	await AnimPlayer.animation_finished
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
	LocationManager.last_jump_position = global_position #gör så vi kan respawna om vi landar fel
	
	
	set_collision_mask_value(7, false) #stänger av kollision m objekt medan man hoppar, så kan man hoppa mellan platformar
	
	jump_start_pos = global_position
	jump_direction = Vector2.DOWN.rotated(JumpRaycast.global_rotation).normalized()
	velocity = jump_direction * jump_speed

func _enter_water_state():
	state = WATER

func _enter_attack_state():
	state = ATTACK
	

########## SIGNALS ########

func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if state != ATTACK:
		return
	if body.is_in_group("enemies"):
		body._take_damage()
