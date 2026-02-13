extends CharacterBody2D


const MAX_SPEED = 120
const ACC = 1100
const ATTACK_RANGE = 70


enum { CHASE, ATTACK_1, ATTACK_2, SUMMON, DEAD }
var state = CHASE


var health = 14
var direction_name = "left"
var target = null
var player = null
var active = false
var can_summon = true
@onready var anim = $AnimationPlayer
@onready var summon_scenes = load("res://Scenes/executioner_summons.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	target = player
	_update_healthbar()
	
func _physics_process(delta: float) -> void:
	if not active:
		return
	match state:
		CHASE:
			_chase_state(delta)
		ATTACK_1, ATTACK_2, SUMMON:
			_movement(delta, Vector2.ZERO) # Stå still under attacker
		DEAD:
			_dead_state(delta)
# ------------------------------
# Central rörelsefunktion
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC * delta)
	move_and_slide()

# ------------------------------
# State logik
# ------------------------------


func _chase_state(delta: float) -> void:
	if not target: return
	var direction_to_player = global_position.direction_to(target.global_position)
	var distance_to_player = global_position.distance_to(target.global_position)
	
	
	if health < 15 and can_summon: #När under 10 hp så summonar han sina småttingar
		state = SUMMON
		can_summon = false
		anim.play("Summon")

		for child in get_parent().get_children():
			if child.is_in_group("summons"):
				child.has_been_summoned = true
				
		
		return

	
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player)
	
	# Om vi är inom räckhåll, attackera
	if distance_to_player < ATTACK_RANGE and not anim.is_playing():
		print("ENTER ATTACK STATE")
		_enter_attack_state()

func _dead_state(delta: float) -> void:
	queue_free()
	$"../Boss_Arena_doors".enabled = false
	$"..".boss_alive = false
# ------------------------------
# Attack Logik (Slumpad)
# ------------------------------

func _enter_attack_state():
	

	var r = randf()
	if r < 0.5:
		state = ATTACK_1
		anim.play("Attack1_" + direction_name)
	else:
		state = ATTACK_2
		anim.play("Attack2_" + direction_name)
	
	_enter_chase_state()

func _enter_chase_state() -> void:
	state = CHASE


# ------------------------------
# Hjälpfunktioner
# ------------------------------

func _take_damage():
	health -= 1
	_update_healthbar()
	print("tar skada")
	if health <= 0:
		_enter_dead_state()

func _update_healthbar() -> void:
	print("healhtbar updateras")
	$Healthbar.value = health


func _update_direction(direction: Vector2):
	if direction.x > 0:
		direction_name = "right"
	elif direction.x <= 0:
		direction_name = "left"

func _enter_dead_state():
	state = DEAD
	anim.play("Death")
	# Vänta på dödsanimation eller queue_free()



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state in [ATTACK_1, ATTACK_2, SUMMON]:
		state = CHASE


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body._take_damage(1)
