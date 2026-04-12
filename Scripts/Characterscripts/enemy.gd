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

@export var health: int

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var lost_sight_timer: Timer = $LostSightTimer

func _ready() -> void:
	"
	_update_healthbar anropas, så att den är fylld vid starten
	"
	_update_healthbar()

func _physics_process(delta: float) -> void:
	"
	State machine för goblinen. Hanterar alla states goblinen kan vara i
	_update_sight uppdateras.
	"
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
	"
	Uppdaterar goblinens movement baserat på riktning vectoren som är en riktning mot spelaren.
	"
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * move_speed, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC * delta)
	move_and_slide()

func _update_direction(direction: Vector2) -> void:
	"
	Baserat på riktningen till spelaren definieras variabeln direction name, så att rätt animation spelas
	"
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

func _update_sight() -> void: 
	"
	Funktion som mha raycast jagar spelarn om den är synlig. Raycasten riktas från goblinen till spelaren
	Om den kolliderar med något annat än spelaren, och spelaren därmed är ur goblinens syn, så tappar goblinen spelaren ur sikte
	Efter det inleds slow chase och han går långsamt, sen efter en timer börjar han idla. 
	Ser han spelaren jagar han spelaren. 
	"
	var raycast_direction = (player.global_position - global_position).normalized()
	raycast.target_position = raycast_direction*300
	raycast.force_raycast_update() 
	if raycast.is_colliding():
		var collided_with = raycast.get_collider() 
		if collided_with == player: #spelarn syns
			raycast_direction = (player.global_position - global_position).normalized()

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
	"
	Anropas när spelaren skadar goblinen. Om hp = 0 anropas _enter_dead_state
	Healthbar uppdateras.
	"
	health -= 1
	if health <= 0:
		_enter_dead_state()
	_update_healthbar()
		
		
func _update_healthbar() -> void:
	"
	Healthbar uppdateras för att matcha health variabeln.
	"
	$Healthbar.value = health
#------------------------------
#State functions
#------------------------------

func _idle_state(delta: float) -> void:
	"
	Han är idle när spelaren är ur syn. Han står still och animation körs.
	"
	anim.play("Idle")
	_movement(delta, Vector2.ZERO, 0)

func _walk_state(delta: float) -> void:
	"
	Goblin går mot spelaren om raycasten kolliderar med spelaren. Om slow chase är true blir han långsam. 
	Walk animation spelas och movement anropas där current_speed skickas in beroende på om det är slow chase eller inte
	"
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
	"
	Attack animation körs i left, right, up eller down och skadar spelaren om han är nog nära. Om spelaren är 50 pixlar anropas _enter_walk_state
	"
	_movement(delta, Vector2.ZERO, 0)
	if $AttackTimer.is_stopped(): #Attack m cooldown
		anim.play("Attack_" + direction_name)
		
		player._take_damage(1,true)
		$AttackTimer.start()
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > 50:
		_enter_walk_state()

func _dead_state(_delta:float) -> void:
	"
	Anropas i take_damage när han har 0 HP- 
	"
	queue_free() #tar bort fienden från spelet
	emit_signal("dead", self)
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	"
	Gör state till IDLE så goblinen kommer in i _idle_state
	"
	state = IDLE


func _enter_walk_state():
	"
	Gör state till WALK så goblinen kommer in i _walk_state
	"
	state = WALK


func _enter_attack_state():
	"
	Gör state till ATTACK så goblinen kommer in i _attack_state
	"
	$AttackTimer.start()
	state = ATTACK


func _enter_dead_state():
	"
	Gör state till DEAD så goblinen kommer in i _dead_state
	"
	state = DEAD
###### SIGNALS# ########

func _on_area_2d_body_entered(body: Node2D) -> void:
	"
	Goblin har en detection area, så den börjar enbart jaga när spelaren först går in i detection arean.
	"
	if body.is_in_group("player"):
		player = body
		chasing = true
		_enter_walk_state()


func _on_lost_sight_timer_timeout() -> void:
	"
	När han först tappar synen på spelaren startas denna timer, och när han har slow chaseat en stund, så är timern sluta
	och _enter_idle_state anropas.
	"
	slow_chase = false
	_enter_idle_state()

func _on_attack_range_body_entered(_body: Node2D) -> void:
	"
	När spelaren kommer inom attack range arean anropas _enter_attack_state
	"
	_enter_attack_state()
