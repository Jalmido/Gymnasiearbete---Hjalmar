extends CharacterBody2D

var start_boss_fight = false



func _process(delta: float) -> void:
	if not start_boss_fight:
		return


signal dead(enemy: Enemy)

const ACC = 1100
var speed: int = 80
enum { IDLE, WALK, DEAD, DASH, SHOOT}

var state = WALK
var direction_name: String = "up"
var player 
var health: int = 20
var attacking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var animplayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var current_scene:String = get_tree().current_scene.scene_file_path
	print(current_scene)
	if current_scene == "res://Scenes/Yunion/the_yunion.tscn":
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue2.json"
	else:
		$Dialogue1.dialogue_file = "res://Interaction/Dialogue/ElderSoren_dialogue1.json"

	_update_healthbar()
	player = get_tree().get_first_node_in_group("player")

	
func _physics_process(delta: float) -> void:
	if not start_boss_fight:
		return
	$Healthbar.show()
	$InteractionArea.set_deferred("monitoring", false)
		
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
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, ACC * delta)
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

#------------
#Health och damage
#-----------------

func _take_damage():


		
	health -= 1
	if health <= 0:
		_enter_dead_state()
	
	if health < 8:
		speed = 80
		$AnimatedSprite2D.modulate.b = 0		
		$AnimatedSprite2D.modulate.r = 1.0
		$AnimatedSprite2D.modulate.g = 0	
		
	_update_healthbar()
	
func _update_healthbar() -> void:
	$Healthbar.value = health
	
func choose(array):
	array.shuffle() #godot funktion
	return array.front()
	


#------------------------------
#State functions
#------------------------------
func _idle_state(delta: float) -> void:
	_movement(delta, Vector2.ZERO)
	if start_boss_fight:
		_enter_walk_state()
		
func _walk_state(delta: float) -> void:
	speed = 80
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= 100 and not attacking: #går bara t attack om den inte redan attackerar
		_enter_attack_state()

	elif distance_to_player < 50: #så man int fastnar i varandra
		direction_to_player -= direction_to_player * 0.5
	
	
	_update_direction(direction_to_player)
	_movement(delta, direction_to_player)

func _dash_state(delta: float) -> void:
	var dash_dir = global_position.direction_to(player.global_position)
	speed = 200
	_movement(delta, dash_dir)
	
	
func _dead_state(_delta:float) -> void:
	emit_signal("dead", self)
	queue_free() #tar bort fienden från spelet

# ------------------------------
# Enter state functions
# ------------------------------
func _enter_idle_state():
	state = IDLE

	
func _enter_walk_state():
	state = WALK

func _enter_dead_state():
	state = DEAD
	
func _enter_attack_state():
	attacking = true
	state = choose([SHOOT, DASH]) #slumpar mellan dash och shoot
	if state == SHOOT:
		animplayer.play("Shoot")
	elif state == DASH:
		animplayer.play("Dash_" + direction_name)
	await animplayer.animation_finished
	attacking = false
	if state == SHOOT:
		$AfterShootIdleTimer.start()
	elif state == DASH:
		$AfterDashIdleTimer.start()
	
	
###### SIGNALS# ########



func _on_after_attack_idle_timer_timeout() -> void:
	print("HAR ATTACKERAT OCH SKA BÖRJA GÅ")
	_enter_walk_state()


func _on_laser_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body._take_damage(1)
