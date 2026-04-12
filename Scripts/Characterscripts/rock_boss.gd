extends CharacterBody2D
class_name Boss

signal dead(Enemy, enemy)

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
	"
	Fixar healthbar, startar idle animation på bossen och definierar att detta är ett boss room så att man respawnar med full hp.
	"
	_update_healthbar()
	player = get_tree().get_first_node_in_group("player")
	anim.play("Idle_up")
	Globals.boss_room = true #Gör så att man respawnar m 3 hjärtan, för att göra det lite lättare
	
func _physics_process(delta: float) -> void:
	"
	State machine för bossen. Hanterar alla states bossen kan vara i
	"
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
			var slow_move = global_position.direction_to(player.global_position) * 0.5
			_movement(delta, slow_move)
		STOMP:
			_movement(delta, Vector2.ZERO)

	


#------------------------------
#Movement helper
#------------------------------

func _movement(delta: float, direction: Vector2) -> void:
	"
	Uppdaterar bossens movement baserat på riktning vectoren som är en riktning mot spelaren.
	"
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, ACC * delta)
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

#------------
#Health och damage
#-----------------

func _take_damage():
	"
	Anropas när bossen tar damage av playern. Om den har 10 eller lägre går han snabbare och slår mer frekvent
	"
	if not active:
		return
		
	health -= 1
	if health <= 0:
		_enter_dead_state()
	
	if health <= 10:
		speed = 100
		anim.modulate = Color(1.5,0.5,0.5)
		$AfterStompIdleTimer.wait_time = 0.3
		$AfterSwipeIdleTimer.wait_time = 0.15

	_update_healthbar()
	
func _update_healthbar() -> void:
	"
	Anropas i take_damage funktionen och ändrar healthbaren som visas i spelet
	"
	$Healthbar.value = health
	
func choose(array):#Hade kunnat använda .pick_random funnktionen som ingår i godot, men visste inte att den fanns... 
	"
	Tar in en lista och blandar om (listan har SWIPE eller STOMP) attackerna
	returnerar den omblandade arrayen
	"
	array.shuffle() #godot funktion
	return array.front()
	


#------------------------------
#State functions
#------------------------------
func _idle_state(delta: float) -> void:
	"
	Han är idle när han inte är aktiv (innan man har börjat de 3 goblinsen)
	"
	anim.play("Idle_" + direction_name)
	_movement(delta, Vector2.ZERO)
	if active and $AfterSwipeIdleTimer.is_stopped() and $AfterStompIdleTimer.is_stopped():
		_enter_walk_state()
		
func _walk_state(delta: float) -> void:
	"
	Han beräknar riktning och avstånd till player, och om playern är 100 pixlar ifrån så jagar han
	Spelar walk animation
	"
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= 100 and state != SWIPE and state != STOMP: #går bara t attack om den inte redan attackerar
		_enter_attack_state(delta)

	elif distance_to_player < 50: #så man int fastnar i varandra
		direction_to_player -= direction_to_player * 0.5
	
	
	_update_direction(direction_to_player)
	anim.play("Walk_" + direction_name)
	_movement(delta, direction_to_player)


	
func _dead_state(_delta:float) -> void:
	"
	När HP = 0 dör han och då emittas en signal som gör att dörrarna till boss rummet öppnas och man kan gå genom
	Om boss_fight_mode är på (om man valde bossen via startmenyn) visas victory screen
	"
	emit_signal("dead", self)
	queue_free() #tar bort fienden från spelet
	active = false
	Globals.boss_room = false #gör så man inte längre ör i boss room och respawnar m 3 hjärtan
	if Globals.boss_fight_mode:
		Globals.victory_screen_requested.emit()
		Globals.boss_fight_mode = false
	
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	"
	Gör state till IDLE så bossen kommer in i _idle_state
	"
	state = IDLE
	
func _enter_walk_state():
	"
	Gör state till WALK så bossen kommer in i _walk_state
	"
	state = WALK

func _enter_dead_state():
	"
	Gör state till DEAD så bossen kommer in i _dead_state
	"
	state = DEAD
	
func _enter_attack_state(delta:float):
	"
	Om spelaren är nog nära anropas denna.
	Här beräknas riktning till spelaren, och utifrån det ändras variabeln direction_name så att rätt attack spelas
	efter att en attack-typ har slumpats fram i choose funktionen. Efter attacken startar en timer där han idlar.
	"
	var direction_to_player = global_position.direction_to(player.global_position)
	_update_direction(direction_to_player)
	state = choose([STOMP, SWIPE]) #slumpar mellan stomp å swipe.
	if state == STOMP:
		animplayer.play("Stomp_" + direction_name)
		await get_tree().create_timer(1.1667).timeout #så att screen shaken startar när han faktiskt stampar
		$"../Player/Camera2D"._screen_shake(8, 0.5)
	elif state == SWIPE:
		animplayer.play("Swipe_" + direction_name)
	await animplayer.animation_finished
	if state == STOMP:
		$AfterStompIdleTimer.start()
	elif state == SWIPE:
		$AfterSwipeIdleTimer.start()
	
	
###### SIGNALS# ########

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	"
	Spelaren skadas beroende på vilken attack bossen gör. Swipe = 1 damage, Stomp = 2 damage
	"
	if body.is_in_group("player") and $AfterSwipeIdleTimer.is_stopped() and $AfterStompIdleTimer.is_stopped():
		var damage: int
		if state == SWIPE:
			damage = 1
		elif state == STOMP:
			damage = 2
		body._take_damage(damage, true)

func _on_after_attack_idle_timer_timeout() -> void:
	"
	Han kan börja gå när han har idlat efter sina attacker. 
	"
	_enter_walk_state()
