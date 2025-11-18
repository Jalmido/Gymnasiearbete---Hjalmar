extends CharacterBody2D

class_name Enemy

const MAX_SPEED = 80
const ACC = 1100

enum { IDLE, WALK, DEAD, ATTACK }
var state = IDLE
var direction_name = "down"
var prey

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var distance_to_player = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			#_dead_state(delta)
			pass
		ATTACK: 
			_attack_state(delta)
#------------------------------
#Movement helper
#------------------------------

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
	
	anim.play("Idle_" + direction_name)
	_movement(delta, Vector2.ZERO)


func _walk_state(delta: float) -> void:
	#idlar om den int har nå prey
	if prey == null:
		_enter_idle_state()
		
	#lokala variabler
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	var attack_range = 20
	
	#ATTACKLOGIK
	if distance_to_player < attack_range:
		_enter_attack_state()
	
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player)
	
	
func _attack_state(delta:float) -> void:

	anim.play("Attack_" + direction_name)
	_movement(delta, Vector2.ZERO)
	
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


func _enter_walk_state():
	state = WALK

"
func _enter_dead_state():
	state = DEAD

"
func _enter_attack_state():
	state = ATTACK

###### SIGNALS# ########

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		prey = body
		_enter_walk_state()
		


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		prey = 0
		_enter_idle_state()
