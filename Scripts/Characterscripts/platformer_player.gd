extends CharacterBody2D

const MAX_SPEED = 200.0
const ACC = 1500.0
const SWIM_FORCE = -100.0 
const GRAVITY = 400.0      
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
const SWIM_ACCEL = -600.0 
const MAX_SWIM_SPEED = -300.0 

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
	"
	State machine för player. Hanterar alla states spelaren kan vara i
	"
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
	"
	Dash baren uppdateras varje frame
	"
	_update_dash_bar()


# ------------------------------
# Central rörelsefunktion
# ------------------------------

func _movement(delta: float, input_x: float, apply_gravity: bool = true) -> void:
	"
	Uppdaterar playerns movement baserat på ett flyttal mellan -1 och 1. Om 0 så står man still, annars rör man sig höger eller vänster. 
	Om man inte är på golvet, appliceras gravitation per automatik och man flyttas ner
	"
	if input_x != 0:
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, ACC * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACC * delta)
	
	
	if apply_gravity and not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func _update_direction(axis: float) -> void:
	"
	Tar in flyttal mellan -1 och 1 beroende på input från A och D. Används för animations
	"
	if axis > 0:
		direction_name = "right"
	elif axis < 0:
		direction_name = "left"


func _change_hotbar_item(item_name: String) -> void:
	"
	Här hanteras logiken för vilket item som är equipat. Hardcodeat eftersom jag har så pass få items. Denna anropas i Hotbar.gd scripten
	varje gång man byter item. 
	Ex: Om man selectar pistolen, så kommer det att vara det item_name som matas in från Hotbar.gd, då button noden för
	pistolen heter Pistol och därmed kommer den if-satsen bli aktiv
	I platformer player kan man ej slå. 
	"
	$Handgun.disable_weapon()

	if item_name == "Pistol":
		$Handgun.enable_weapon()
		attacking = false

	elif item_name == "Health_Potion":
		current_item = "Health_Potion"
		attacking = false
 
func _drink_potion() -> void:
	"
	Om man har en health_potion i sitt inventory, så kan man dricka den och få hp. Health potions lagras i Global variablar.
	"
	if Globals.health_potions_in_inv > 0 and Globals.lives < 4:
		Globals.lives += 1
		Globals.health_potions_in_inv -= 1


func _take_damage(amount: int) -> void:
	"
	När spelaren tar skada (av bossen eller hans summons), så anropas denna. Man tappar hp beroende på vilken attack som man tog emot (parametern amount)
	"
	if not can_take_damage:
		return
	
	if can_take_damage:
		can_take_damage = false
		$DamageCooldownTimer.start()
		Globals.lives -= amount

		if Globals.lives <= 0:
			_enter_dead_state()

func _start_dash_cooldown():
	"
	Cooldown för dashen börjas. Anropas när man har dashat klart.
	"
	progressbar.value = 0.0
	cooldown_timer.start(cooldown_duration) 

func _update_dash_bar():
	"
	Uppdaterar dash baren så att den fylls upp med tiden. Anropas i process.
	"
	if not can_dash:
		var time_passed = cooldown_timer.wait_time - cooldown_timer.time_left
		progressbar.value = time_passed
	else:
		progressbar.value = cooldown_duration
# ------------------------------
# State logik
# ------------------------------

func _input(event: InputEvent) -> void:
	"
	Övriga inputs som inte är typ att simma eller gå hanteras här. Dash och attack (som inte bör heta attack, utan typ use) används här
	"
	if event.is_action_pressed("Shift"):
		_enter_dash_state()
	if event.is_action_pressed("Attack"):
		if current_item == "Health_Potion":
			_drink_potion()
		else:
			pass

func _idle_state(delta: float) -> void:
	"
	När spelaren är i IDLE staten, står man still och Idle animation spelas. Om man börjar gå (input axis ökar eller minskar) anropas _enter_walk_state.
	Om man trycker space anropas _enter_swim_state
	"
	anim.play("Idle_" + direction_name)

	_movement(delta, 0)
	
	var axis = Input.get_axis("Left", "Right")
	if axis != 0 and is_on_floor():
		_enter_walk_state()
	
	if Input.is_action_just_pressed("Jump"):
		_enter_swim_state() 

func _walk_state(delta: float) -> void:
	"
	När spelaren är i WALK staten. Hanterar Swim animationen. Uppdaterar kontinuerligt axis,
	som används för animationer och movement.
	"
	
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
	"
	När man håller space anropas denna. Swim animationen spelas och movement höger och vänster kontrolleras via axis variabeln.
	Ens velocity i y-led ökar när man håller space. 
	"
	anim.play("Swim_" + direction_name) 
	var axis = Input.get_axis("Left", "Right")
	_update_direction(axis)

	var is_swimming_up = Input.is_action_pressed("Jump")

	if is_swimming_up:
		velocity.y = move_toward(velocity.y, MAX_SWIM_SPEED, abs(SWIM_ACCEL) * delta)


	_movement(delta, axis, not is_swimming_up)
	
	if is_on_floor() and velocity.y >= 0:
		if axis == 0:
			_enter_idle_state()
		else:
			_enter_walk_state()

func _dash_state(delta: float) -> void:
	"
	Om man trycker shift, så anropas _enter_dash_state vilket i sin tur anropar denna. 
	Här uppdateras tiden dashen har körts mha delta. 
	"
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED

	move_and_slide() 
	
	if dash_timer <= 0:
		set_collision_mask_value(3, false)
		state = SWIM if not is_on_floor() else IDLE

func _dead_state(delta: float) -> void:
	"
	Om HP = 0 anropas denna via _take_damage och _enter_dead_state och Death screen visas.
	"
	$Death_screen.show()
	get_tree().paused = true
# ------------------------------
# Enter state funktioner
# ------------------------------

func _enter_idle_state():
	"
	Gör state till IDLE så man kommer in i _idle_state
	"
	state = IDLE

func _enter_walk_state():
	"
	Gör state till WALK så man kommer in i _walk_state
	"
	state = WALK

func _enter_swim_state():
	"
	Gör state till SWIM så man kommer in i _swim_state och bestämmer att velocity i y-led nu är SWIM_FORCE
	"
	state = SWIM
	velocity.y = SWIM_FORCE

func _enter_dash_state():
	"
	Återställer dash timern, och bestämmer i vilken riktning dashen kommer ske. 
	"
	if state == DASH or not can_dash: 
		return
	
	state = DASH
	dash_timer = DASH_DURATION
	

	var axis = Input.get_axis("Left", "Right")
	if axis != 0:
		dash_direction = Vector2(axis, 0)
	else:
		if direction_name == "right":
			dash_direction = Vector2.RIGHT
		else:
			dash_direction = Vector2.LEFT
	set_collision_mask_value(3, false)
	can_dash = false
	_start_dash_cooldown()
	
func _enter_dead_state():
	"
	Gör state till DEAD så man kommer in i _dead_state
	"
	state = DEAD

func _on_dash_area_body_entered(body: Node2D) -> void:
	"
	Skadar fiender om man dashar in i de
	"
	if state == DASH:
		body._take_damage()


func _on_damage_cooldown_timer_timeout() -> void:
	"
	Damage cooldown så man inte tar massa skada samtidigt
	"
	can_take_damage = true


func _on_dash_cooldown_timer_timeout() -> void:
	"
	När dash cooldown är klar kan man dasha igen.
	"
	can_dash = true
