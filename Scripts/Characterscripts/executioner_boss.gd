extends CharacterBody2D


const MAX_SPEED = 120
const ACC = 1100
const ATTACK_RANGE = 70


enum { CHASE, ATTACK_1, ATTACK_2, SUMMON, DEAD }
var state = CHASE


var health = 20
var direction_name = "left"
var target = null
var player = null
var active = false
var can_summon = true
@onready var anim = $AnimationPlayer
@onready var summon_scenes = load("res://Scenes/Characters/Characterscripts/executioner_summons.tscn")

func _ready() -> void:
	"
	Gör det till ett boss room, så man respawnar m 3 hp, definierar player för bossen.
	"
	player = get_tree().get_first_node_in_group("player")
	target = player
	_update_healthbar() 
	Globals.boss_room = true #Gör så att man respawnar m 3 hjärtan, för att göra det lite lättare
	
	
func _physics_process(delta: float) -> void:
	"
	State machine för bossen. Hanterar alla states bossen kan vara i
	När han attackerar/summonar är han still
	"
	if not active:
		return
	match state:
		CHASE:
			_chase_state(delta)
		ATTACK_1, ATTACK_2, SUMMON:
			_movement(delta, Vector2.ZERO) #ska bara stå still uner attacker
		DEAD:
			_dead_state(delta)
# ------------------------------
# Central rörelsefunktion
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	"
	Uppdaterar bossens movement baserat på riktning vectoren som är en riktning mot spelaren.
	"
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC * delta)
	move_and_slide()

# ------------------------------
# State logik
# ------------------------------


func _chase_state(delta: float) -> void:
	"
	Bossen beräknar riktning och avstånd till spelaren och jagar spelaren. Är han under 10 hp summonar han 3 summons.
	Om avståndet till spelaren är nära nog kommer _enter_attack_state anropas
	"
	if not target: 
		return
	var direction_to_player = global_position.direction_to(target.global_position)
	var distance_to_player = global_position.distance_to(target.global_position)
	
	
	if health < 10 and can_summon: #När under 10 hp så summonar han sina småttingar
		state = SUMMON
		can_summon = false
		anim.play("Summon")

		for child in get_parent().get_children():
			if child.is_in_group("summons"):
				child.has_been_summoned = true

		return

	
	_update_direction(direction_to_player)
	_movement(delta, direction_to_player)
	

	if distance_to_player < ATTACK_RANGE and not anim.is_playing():
		_enter_attack_state()

func _dead_state(delta: float) -> void:
	"
	Om HP = 0 dör bossen och dödsanimationen spelas. Om boss_fight_mode är true kommer en victory screen upp.
	"
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	$"../../Boss_Arena_doors".enabled = false
	$"../..".boss_alive = false
	queue_free()
	Globals.boss_room = false #gör så man inte längre är i boss fight och därmed inte respawnar m 3 hjärtan
	if Globals.boss_fight_mode: #Om boss fight mode är aktivt, så visas victory screen
		Globals.victory_screen_requested.emit()
		Globals.boss_fight_mode = false


# ------------------------------
# Attack Logik (Slumpad)
# ------------------------------

func _enter_attack_state():
	"
	Anropas när spelaren är inom 70 pixlar från bossen. Då randomizear bossen en attack.
	"
	var r = randf()
	if r < 0.5:
		state = ATTACK_1
		anim.play("Attack1_" + direction_name)
	else:
		state = ATTACK_2
		anim.play("Attack2_" + direction_name)
	
	_enter_chase_state()

func _enter_chase_state() -> void:

	"
	Gör state till CHASE så bossen kommer in i _chase_state
	
	"
	state = CHASE


# ------------------------------
# Hjälpfunktioner
# ------------------------------

func _take_damage():
	"
	Vid attack från player tar bossen skada. Healthbar uppdateras och om HP = 0 dör han
	"
	health -= 1
	_update_healthbar()
	if health <= 0:
		_enter_dead_state()

func _update_healthbar() -> void:
	"
	Uppdaterar healthbaren in game till hp värdet.
	"
	$Healthbar.value = health


func _update_direction(direction: Vector2):
	"
	Ändrar direction_name till right eller left, beroende på riktning till spelaren, så spelas rätt animation. 
	"
	if direction.x > 0:
		direction_name = "right"
	elif direction.x <= 0:
		direction_name = "left"

func _enter_dead_state():
	"
	Gör state till DEAD så bossen kommer in i _dead_state
	"
	state = DEAD
	anim.play("Death")




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	"
	När animation är färdigspelad anropas denna, och han börjar jaga igen.
	"
	if state in [ATTACK_1, ATTACK_2, SUMMON]:
		state = CHASE


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	"
	Om han attackerar spelaren, så anropas take_damage med ett amount i spelarent _take_damage funktion
	"
	if body.is_in_group("player"):
		body._take_damage(1)
