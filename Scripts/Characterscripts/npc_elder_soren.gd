extends CharacterBody2D
signal dead(enemy: Enemy)

const ACC = 1100
var speed: int = 70
enum { IDLE, WALK, DEAD, DASH, SHOOT}

var start_boss_fight = false
var state = WALK
var direction_name: String = "up"
var player 
var health: int = 40
var attacking: bool = false
var prepared_for_boss = false
var dash_direction: Vector2
var heals_from_bullets = false #efter 50% hp healar han
var rage_mode = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var animplayer: AnimationPlayer = $AnimationPlayer

@export var boss_music: AudioStream

func _ready() -> void:
	"
	Då han förekommer 2 gånger i spelet, med olika logik varje gång, är det en del i ready funktionen.
	Först kontrolleras vilken scen man är i, vilket leder till att rätt dialogue fil läses upp vid interaktion.
	Är man i första området, så kan man efter dialogen hoppa ner i hålet ner i underground. 
	Är man i slutområdet startas bossfighten efter dialogen. 
	"
	var current_scene:String = get_tree().current_scene.scene_file_path
	if current_scene == "res://Scenes/Yunion/the_yunion.tscn":
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue2.json"
	else:
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue1.json"
		Globals.objective_recieved = true

	_update_healthbar()
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	"
	Förbereder först för bossen och sedan körs state machinen, som styr logiken för alla states han kan vara i.
	"
	if not start_boss_fight:
		return
	elif not prepared_for_boss:
		_boss_preparations()
		
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
		DASH:
			_dash_state(delta)
		SHOOT:
			pass

	


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



#------------
#Health och damage
#-----------------
func _recieve_health():
	"
	Om spelaren skjuter honom när han har under hälften HP, så healar han 2 hp per skott.
	"
	if heals_from_bullets:
		health += 2
	_update_healthbar()
	
func _take_damage():
	"
	Tar skada när spelaren skadar honom. Om under 20, så blir han röd, och spelaren kan ej skjutskada honom.
	"
	if not start_boss_fight:
		return
	health -= 1
	if health <= 0:
		_enter_dead_state()
	
	if health <= 20 or rage_mode:
		rage_mode = true
		$AnimatedSprite2D.modulate.b = 0		
		$AnimatedSprite2D.modulate.r = 1.0
		$AnimatedSprite2D.modulate.g = 0	
		
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
	
func _boss_preparations():
	"
	Små förberedelser inför bossfight. Man kan skada han och healthbaren kommer upp, samt bossmusiken körs
	"
	$Healthbar.show()
	$InteractionArea.set_deferred("monitoring", false)
	MusicManager.play_track(boss_music)
	prepared_for_boss = true

#------------------------------
#State functions
#------------------------------

func _idle_state(delta: float) -> void:
	"
	Anropas när state blir IDLE av _enter_idle_state. Har ingen animation, så gör bara movement till 0.
	"
	_movement(delta, Vector2.ZERO)



func _walk_state(delta: float) -> void:
	"
	Anropas när state blir WALK från _enter_walk_state. Beräknar avstånd och riktning till player.
	Är spelaren nog nära anropas _enter_attack_state
	Anropar _movement så han går mot spelaren.
	"
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= 100 and not attacking: #går bara t attack om den inte redan attackerar
		_enter_attack_state()

	elif distance_to_player < 50: #så man int fastnar i varandra
		direction_to_player -= direction_to_player * 0.5
	
	
	_update_direction(direction_to_player)
	_movement(delta, direction_to_player)

func _dash_state(delta: float) -> void:
	"
	Anropas när state blir DASH från _enter_attack_state.
	_enter_attack_state beräknar en riktning, som sedan används som movement-riktning i denna funktion
	"
	_movement(delta, dash_direction)
	
	
func _dead_state(_delta:float) -> void:
	"
	Om HP = 0 dör bossen och victoryanimationen spelas. Om boss_fight_mode är true kommer en victory screen upp.
	"
	if Globals.boss_fight_mode: #om boss fight mode är på, så visas
		Globals.victory_screen_requested.emit()
		Globals.boss_fight_mode = false
		return
	#Victory cutscene om det är story mode
	$LaserPivot/LaserAttackHitbox.monitoring = false #så han ej har ute lasern och slaktar en när han håller på att dö
	set_physics_process(false)
	$"../Player/Camera2D".enabled = false
	$"../Cutscene/Camera2D".make_current()
	$"../Cutscene/AnimationPlayer".play("VictoryAnimation")
	
	$Healthbar.hide()
	#queue_free()

	

func _after_attack_done():
	"
	Anropas i _enter_attack_state
	Gör att bossens hastighet återställs till vanligt och att timers startar så han idlar efter attacken.
	"
	if health <= 20:
		speed = 110
	else:
		speed = 70

	if state == SHOOT:
		$AfterShootIdleTimer.start()
	elif state == DASH:
		$AfterDashIdleTimer.start()
	
	state = IDLE 
# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	"
	Gör state till IDLE så bossen kommer in i _idle_state
	"
	state = IDLE
	animplayer.play("Levitating")
	
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
	
func _enter_attack_state():
	"
	Gör state till SHOOT eller DASH, beroende på vad som slumpas fram. 
	Om state är SHOOT slumpas en riktning fram, som avgör vilket håll han skjuter (snurrar).
	Om state är DASH tas riktningen dash_direction till spelaren. Sedan roteras en synlig pil i den riktningen, som visas 
	snabbt innan dashen utförs. Själva dashen är att hastigheten höjs till 350, och om han träffar playern under dashen så skadas spelaren.
	Dashen sker i _dash_state funktionen.
	"
	attacking = true
	state = choose([SHOOT, DASH]) #slumpar mellan dash och shoot
	if state == SHOOT:
		var shot_direction = choose(["Left", "Right"])
		animplayer.play("Shoot_" + shot_direction)
		await get_tree().create_timer(3).timeout
		_after_attack_done()
	elif state == DASH:
		dash_direction = global_position.direction_to(player.global_position)
		$AttackArrowWarning.rotation = get_angle_to(player.global_position) #Varningspil skapas i riktning han ska dasha
		$AttackArrowWarning.show()
		await get_tree().create_timer(0.6).timeout
		speed = 350
		$AttackArrowWarning.hide()
		$DashAttackHitbox.monitoring = true
		await get_tree().create_timer(0.7).timeout
		$DashAttackHitbox.monitoring = false
		_after_attack_done()

	
	
###### SIGNALS# ########



func _on_after_attack_idle_timer_timeout() -> void:
	"
	När han har idlat efter en attack, börjar han gå igen
	"
	attacking = false
	_enter_walk_state()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	"
	Skadar spelaren om attacken träffar spelaren-
	"
	if body.is_in_group("player"):
		body._take_damage(1,true)
