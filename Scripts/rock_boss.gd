extends CharacterBody2D
class_name Boss

signal dead(enemy: Enemy)

const ACC = 1100
var speed: int = 40
enum { IDLE, WALK, DEAD, SWIPE, STOMP}

var state = WALK
var direction_name: String = "up"
var player 
var health: int = 20
var active = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var animplayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_update_healthbar()
	player = get_tree().get_first_node_in_group("player")
	anim.play("Idle_up")
	
func _physics_process(delta: float) -> void:
	if not active: 
		return 
		
		
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
		SWIPE:
			_movement(delta, Vector2.ZERO)
		STOMP:
			_movement(delta, Vector2.ZERO)

	


#------------------------------
#Movement helper
#------------------------------

func _movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, ACC * delta)
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

#---------------
#raycasts å jagasystem
#---------------

#------------
#Health och damage
#-----------------

func _take_damage():
	if not active:
		return
		
	health -= 1
	if health <= 0:
		_enter_dead_state()
	
	if health < 8:
		speed = 80
		$AnimatedSprite2D.modulate.b = 0		
		$AnimatedSprite2D.modulate.r = 1.0
		$AnimatedSprite2D.modulate.g = 0	
		$AfterStompIdleTimer.wait_time = 1.5
		$AfterSwipeIdleTimer.wait_time = 1.0

	_update_healthbar()
	
func _update_healthbar() -> void:
	$Healthbar.value = health
	
func choose(array):
	array.shuffle() #godot funktion
	return array.front()
	


#------------------------------
#State functions
#------------------------------
func _idle_state(delta: float) -> void:
	anim.play("Idle_" + direction_name)
	_movement(delta, Vector2.ZERO)
	if active and $AfterSwipeIdleTimer.is_stopped() and $AfterStompIdleTimer.is_stopped():
		_enter_walk_state()
		
func _walk_state(delta: float) -> void:
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= 100 and state != SWIPE and state != STOMP: #går bara t attack om den inte redan attackerar
		_enter_attack_state()

	elif distance_to_player < 50: #så man int fastnar i varandra
		direction_to_player -= direction_to_player * 0.5
	
	
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player)


	
func _dead_state(_delta:float) -> void:
	emit_signal("dead", self)
	queue_free() #tar bort fienden från spelet
	active = false
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	state = IDLE
	
func _enter_walk_state():
	state = WALK

func _enter_dead_state():
	state = DEAD
	
func _enter_attack_state():
	state = choose([STOMP, SWIPE]) #slumpar mellan stomp å swipe
	if state == STOMP:
		animplayer.play("Stomp_" + direction_name)
	elif state == SWIPE:
		animplayer.play("Swipe_" + direction_name)
	await animplayer.animation_finished
	if state == STOMP:
		$AfterStompIdleTimer.start()
	elif state == SWIPE:
		$AfterSwipeIdleTimer.start()
	
	
###### SIGNALS# ########

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and $AfterSwipeIdleTimer.is_stopped() and $AfterStompIdleTimer.is_stopped():
		var damage: int
		if state == SWIPE:
			damage = 1
		elif state == STOMP:
			damage = 2
		body._take_damage(damage)

func _on_after_attack_idle_timer_timeout() -> void:
	print("HAR ATTACKERAT OCH SKA BÖRJA GÅ")
	_enter_walk_state()
