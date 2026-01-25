extends CharacterBody2D

# --- Konstanter (Från din plattformare) ---
const MAX_SPEED = 120.0
const ACC = 1100.0
const ATTACK_RANGE = 150.0 # Justera efter behov

# --- States ---
enum { CHASE, ATTACK_1, ATTACK_2, SUMMON, DEAD }
var state = CHASE

# --- Boss Variabler ---
var health = 20
var max_health = 20
var direction_name = "left"
var target = null
var active = false
var player = null
@onready var anim = $AnimationPlayer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	_update_healthbar()
	
func _physics_process(delta: float) -> void:
	match state:
		CHASE:
			_chase_state(delta)
		ATTACK_1, ATTACK_2, SUMMON:
			_movement(delta, Vector2.ZERO) # Stå still under attacker

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
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player)
	
	# Om vi är inom räckhåll, attackera
	if distance_to_player < ATTACK_RANGE:
		_enter_attack_state()

# ------------------------------
# Attack Logik (Slumpad)
# ------------------------------

func _enter_attack_state():
	# Slumpa mellan attacker (Här tar vi in Summon-logiken också)
	var r = randf()
	
	if health < 10 and r < 0.3: # Summon om HP är lågt
		state = SUMMON
		anim.play("Summon_" + direction_name)
	elif r < 0.65:
		state = ATTACK_1
		anim.play("Attack1_" + direction_name)
	else:
		state = ATTACK_2
		anim.play("Attack2_" + direction_name)



# ------------------------------
# Hjälpfunktioner
# ------------------------------

func _take_damage():
	if not active: return
	
	health -= 1
	_update_healthbar()
	
	# "Enrage" logik från Rock-bossen (ändra färg/fart)
	if health < 8:
		$Sprite2D.modulate = Color(1, 0.5, 0.5) # Blir rödaktig
	
	if health <= 0:
		_enter_dead_state()

func _update_healthbar() -> void:
	$Healthbar.value = health

func _update_direction(axis: float):
	if axis > 0:
		direction_name = "right"
	elif axis < 0:
		direction_name = "left"

func _enter_dead_state():
	state = DEAD
	anim.play("Death")
	# Vänta på dödsanimation eller queue_free()
