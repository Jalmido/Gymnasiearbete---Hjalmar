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
var jump_direction: Vector2 = Vector2.ZERO
var jump_target_pos: Vector2
var jump_speed = 200
var can_jump = false
var can_take_damage = true
var sword_equipped = false
var ignore_ground = false
var is_respawning = false

@onready var JumpRaycast: RayCast2D = $JumpRayCast
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var DamageCooldownTimer: Timer = $DamageCooldownTimer
@onready var GroundControlRaycast: RayCast2D = $GroundControlRaycast

func _physics_process(delta: float) -> void:
	"
	State machine för player. Hanterar alla states spelaren kan vara i
	"
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
# Överiga funktioner (movement, vapen/items, hopp hjälpfunktioner)
# ------------------------------
func _movement(delta: float, direction: Vector2) -> void:
	"
	Uppdaterar playerns movement baserat på riktning som matas in från states där spelaren rör sig.
	"
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()

func _update_ground_movement():
	"
	Kollar om man går på is eller vanlig mark för att ändra spelarns acc och så, så att man får en glideffekt på isen
	"
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
	"
	Övriga inputs som inte är typ walking hanteras här. Jump och Attack (borde kanske heta use eller liknande, då den inte bara är till för att attackera)
	Så hopp, attack, drick potion och så. Kontrollerar vilket iten som är equipat genom variabeln current_item som ändras när man byter hotbar item.
	"
	
	if event.is_action_pressed("Jump") and can_jump:
		_enter_jump_state()
	if event.is_action_pressed("Attack"):
		if current_item == "Sword" and sword_equipped:
			_enter_attack_state()
		elif current_item == "Health_Potion":
			_drink_potion()


func _update_direction(direction: Vector2) -> void:
	"
	Uppdateras så att animationerna spelas på rätt sätt. (exempelvis om direction_name är right, så spelas Walk_right osv.)
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

func _change_hotbar_item(item_name: String) -> void:
	"
	Här hanteras logiken för vilket item som är equipat. Hardcodeat eftersom jag har så pass få items. Denna anropas i Hotbar.gd scripten
	varje gång man byter item. 
	Ex: Om man selectar pistolen, så kommer det att vara det item_name som matas in från Hotbar.gd, då button noden för
	pistolen heter Pistol och därmed kommer den if-satsen bli aktiv
	"
	$Handgun.disable_weapon()

	if item_name == "Pistol":
		$Handgun.enable_weapon()
		sword_equipped = false
	elif item_name == "Sword":
		current_item = "Sword"
		sword_equipped = true
	elif item_name == "Health_Potion":
		current_item = "Health_Potion"
		sword_equipped = false

func _drink_potion() -> void:
	"
	Om man har en health_potion i sitt inventory, så kan man dricka den och få hp. Health potions lagras i Global variablar.
	"
	if Globals.health_potions_in_inv > 0 and Globals.lives < 4:
		Globals.lives += 1
		Globals.health_potions_in_inv -= 1

func _take_damage(amount: int, play_anim: bool) -> void:
	"
	När spelaren tar skada (av fiende eller ex missat hopp), så anropas denna. Man tappar hp beroende på vilken attack som man tog emot (parametern amount)
	och om play_anim är true, så spelas en kort animation, där spelaren blinkar rött. Spelas inte när man drunknar, därför la jag till den parametern.
	"
	
	if not can_take_damage:
		return
	
	if can_take_damage:
		can_take_damage = false
		DamageCooldownTimer.start()
		if play_anim: #om inte play anim, så spelas ej. Används så man inte blir röd när man drunknar
			AnimPlayer.play("Take_damage")
		$HitSound.play()
		Globals.lives -= amount

		if Globals.lives <= 0:
			print("dog")
			_enter_dead_state()

func _display_raycast() -> void:
	"
	Visar den snurrande pilen runt spelaren. Där man mha tweens säger att värdet rotation på JumpRayCasten ska bli 2PI på 1 sekund, så att spelaren sen kan tajma hoppet
	"
	JumpRaycast.show()
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(JumpRaycast, "rotation", 2*PI, 1.0).as_relative() #Roterar, och as_relative är inbyggd funktion som gör att den fortsätter där den slutade

func _reset_jump_state_after_death() -> void:
	"
	Funktion som resetar jump_state (resetar raycasten och ser till så att jump arean känns av av spelaren)
	"
	
	can_jump = false
	_reset_raycast()
	await get_tree().create_timer(0.05).timeout

	for area in get_tree().get_nodes_in_group("jump_areas"):
		if area.overlaps_body(self):
			print("i gruppen och resetar raycast")
			can_jump = true
			_display_raycast()
func _reset_raycast() -> void:
	"
	resetar raycastens värden
	"
	JumpRaycast.hide()
	JumpRaycast.rotation = 0
	

func _landing_manager() -> void:
	"
	När man hoppat klart anropas denna. Man låser fast playerns position där jump_target_pos är, så att man hamnar precis där man skulle, och sedan slås kollision på igen. 
	Kontrollerar vad man landar på. Landar man på vatten anropas _enter_water_state. Om man är på marken får man fortsätta.
	"
	velocity = Vector2.ZERO
	global_position = jump_target_pos
	set_collision_mask_value(7, true) 
	
	#Tvinga raycasten att kolla vad som finns under fötterna just nu
	GroundControlRaycast.force_raycast_update()
	

	if GroundControlRaycast.is_colliding(): #Kontrollerar om man landar på vatten, och drunknar då
		var collider = GroundControlRaycast.get_collider()
		if collider.is_in_group("water"):
			_enter_water_state()
			return
			
	_enter_idle_state()

# ------------------------------
# State functions
# ------------------------------

func _idle_state(delta: float) -> void:
	"
	När spelaren är i IDLE staten, står man still och Idle animation spelas. Om man börjar gå (input vector ökar eller minskar) anropas _enter_walk_state.
	"
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	if input_vector != Vector2.ZERO:
		_enter_walk_state()
	else:
		anim.play("Idle_" + direction_name)
	
	
	_movement(delta, Vector2.ZERO)

func _walk_state(delta: float) -> void:
	"
	När spelaren är i WALK staten. HAnterar walk animation. Uppdaterar kontinuerligt input_vector,
	som används för animationer och movement.
	"
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
	"
	När HP är 0 anropas denna. Death screen visas.
	"
	$Death_screen.show()
	get_tree().paused = true
	

func _jump_state(_delta: float) -> void:
	"""
	STORT PROBLEM: hade många buggar, men framförallt att man ofta fastnade i väggar när man landade vid hopp. Inte ens CHatten kunde 
	Kom till slut på en lösning som funkade, vilket är en collision shape som i slutet av hopp animationen utökas och går från storlek 0, så att den
	"trycker" ut en från väggen. Klyftig lösning tyckte jag!
	
	När playern är i state JUMP. Här har hopp-beräkningarna redan gjorts i enter_jump_state, så här spelas animationen och när man är nära sitt target snappar man till den. 
	"""
	
	AnimPlayer.play("Jump")
	move_and_slide()
		

	if global_position.distance_to(jump_target_pos) < 5:
		global_position = jump_target_pos
		_landing_manager()

func _water_state(_delta: float) -> void:
	"
	När man hoppar och landing_manager märker att man är i vatten anropas _enter_water_state som anropar denna. 
	Denna gör spelar drowning animation och när den är klar ändras ens position till last_jump_position
	Spelaren skadas också, och om man inte har 0 hp, så får man hoppa igen. 
	"
	velocity = Vector2.ZERO

	if is_respawning:
		return
	is_respawning = true

	AnimPlayer.play("Drowning")
	await AnimPlayer.animation_finished


	AnimPlayer.stop()
	AnimPlayer.play("Reset_visual") #var några buggar förut att man blev liten och grejer, så gjorde denna så man ser normal ut vid respawn. 

	global_position = LocationManager.last_jump_position.snapped(Vector2.ONE) #Respawnar där man hoppa ifrån
	_reset_jump_state_after_death()
	GroundControlRaycast.enabled = true
	set_collision_mask_value(7, true)
	_take_damage(1, false)
	if Globals.lives > 0:
		is_respawning = false
		_enter_idle_state()
	else:
		is_respawning = false #om hp = 0 entrar man inte Idle state, utan man kommer dö istället

func _attack_state(delta: float) -> void:
	"
	Själva attacken görs i _enter_attack_state, medan här hanteras så att man kan gå medan man slår. 
	"
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	_update_ground_movement() 


	_movement(delta, input_vector)
	
	if not AnimPlayer.is_playing():
		_enter_idle_state()

# ----------------------
#Animation funktion
# ----------------------

func _Enter_underground(): #något onödig nu, hade kunnat lösa i annat script
	"
	Tidig funktion jag gjorde för att hoppa in i undergjorden i början av spelet.
	"
	AnimPlayer.play("Enter_underground")

# ------------------------------
# Enter state functions
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

func _enter_dead_state():
	"
	Gör state till DEAD så man kommer in i _dead_state
	"
	state = DEAD

func _enter_jump_state():
	"
	Beräkningarna och förberedelserna till själva hoppet sker här. Anropas i Input funktionen när man kan hoppa (är på hopp area). 
	Startpositionen vid hoppet sparas i global position så man kan respwna om man missar hoppet. Kollisioner slås av under hoppet så man kan fara genom väggar och slås på när man landar i landing_manager.
	Hoppets riktning bestäms genom att kolla vad JumpRayCastens rotation var vid hoppet och sparas ner. Sedan multipliceras den med hoppdistansen, så då har man sin färdiga hoppbana beräknad.
	Sedan flyttas man med velocity (riktningen*hastigheten) och i Jump_state kommer man sedan stanna av när man närmar sig sin target position. 
	"
	state = JUMP
	
	LocationManager.last_jump_position = global_position #sparar varifrån vi hoppade i globalscript
	
	set_collision_mask_value(7, false)

	jump_direction = Vector2.DOWN.rotated(JumpRaycast.global_rotation).normalized()

	#BESTÄM LANDNINGSPOSITION
	jump_target_pos = global_position + jump_direction * MAX_JUMP_DISTANCE

	velocity = jump_direction * jump_speed
func _enter_water_state():
	"
	Gör state till WATER så man kommer in i _water_state
	"
	state = WATER

func _enter_attack_state():
	"
	Attackanimation spelas (den hanterar damaging av fiender och så vidare) och ljud spelas.
	"
	anim.modulate = Color(1, 1, 1, 1) #gör så han int blir röd om man attackerar mitt i take_damade animationen
	state = ATTACK
	AnimPlayer.play("Attack_" + direction_name)
	if not $SwordSound.playing:
		$SwordSound.play()


########## SIGNALS ########

func _on_damage_cooldown_timer_timeout() -> void:
	"
	När man tar damage startas timer som är cooldown, så man inte kan ta massa skada på samma gång. Vid timeout kan man ta skada igen. 
	"
	can_take_damage = true

func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	"
	Hanteras i animationplayer vid attack. Om sword_hitboxen träffar enemy tar fienden skada. 
	"
	if state != ATTACK:
		return
	if body.is_in_group("enemies"):
		body._take_damage()
