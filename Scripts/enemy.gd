extends CharacterBody2D
class_name Enemy

signal dead(enemy: Enemy)

const ACC = 1100
var speed: int = 80
enum { IDLE, WALK, DEAD, ATTACK }

var state = IDLE
var direction_name: String
var chasing = false
var slow_chase = false
var player
var health: int = 5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var lost_sight_timer: Timer = $LostSightTimer

func _ready() -> void:
	_update_healthbar()

func _physics_process(delta: float) -> void:

	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
		ATTACK: 
			_attack_state(delta)
	
	if player:
		_update_sight()
	


#------------------------------
#Movement helper
#------------------------------

func _movement(delta: float, direction: Vector2, move_speed: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * move_speed, ACC * delta)
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

func _update_sight() -> void: #funktion som mha raycast jagar spelarn om den är synlig
	var raycast_direction = (player.global_position - global_position).normalized()
	raycast.target_position = raycast_direction * 500
	
	raycast.force_raycast_update() 
	
	if raycast.is_colliding():
		var collided_with = raycast.get_collider() 
		if collided_with == player: #spelarn syns
			chasing = true 
			slow_chase = false
			lost_sight_timer.stop()
		else: #Just ny ser enemyn inte spelarn
			if chasing == true:
				chasing = false
				slow_chase = true
				lost_sight_timer.start()
#------------
#Health och damage
#-----------------

func _take_damage():
	health -= 1
	if health <= 0:
		_enter_dead_state()
	_update_healthbar()
	
func _update_healthbar() -> void:
	$Healthbar.value = health
	
#------------------------------
#State functions
#------------------------------
func _idle_state(delta: float) -> void:
	anim.play("Idle")
	_movement(delta, Vector2.ZERO, 0)

func _walk_state(delta: float) -> void:
	#idlar om den int har nån player att jaga
	if player == null:
		_enter_idle_state()
		return
		
	if not chasing and not slow_chase:
		_enter_idle_state()
		return
		
	#lokala variabler
	var direction_to_player = global_position.direction_to(player.global_position)


	
	#hastighetsloigik om slowchase är true
	var speed_multiplier = 1.0
	if slow_chase:
		speed_multiplier = 0.4

	var current_speed = speed * speed_multiplier
		
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player, current_speed)

func _attack_state(delta:float) -> void:
	anim.play("Attack_" + direction_name)
	
	var distance_to_player = global_position.distance_to(player.global_position)

	
	if distance_to_player > 40:
		_enter_walk_state()
	player._take_damage(1)
	_movement(delta, Vector2.ZERO, 0)

func _dead_state(_delta:float) -> void:
	queue_free() #tar bort fienden från spelet
	emit_signal("dead", self)
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	state = IDLE


func _enter_walk_state():
	state = WALK


func _enter_attack_state():
	state = ATTACK

func _enter_dead_state():
	state = DEAD
###### SIGNALS# ########

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		chasing = true
		_enter_walk_state()
		


func _on_lost_sight_timer_timeout() -> void:
	slow_chase = false
	_enter_idle_state()



func _on_attack_range_body_entered(_body: Node2D) -> void:
	_enter_attack_state()
