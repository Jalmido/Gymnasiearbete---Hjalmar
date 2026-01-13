extends Node2D
class_name pistol


var bullet_velocity = 2000
var is_shooting = false
var bullet_direction = Vector2.ZERO
var pistol_active = false
var can_shoot = false

@onready var bullet: Area2D = $Bullet
@onready var handgun: Node2D = $"."

func _ready() -> void:
	if Globals.ammo_in_mag > 0:
		can_shoot = true

func _process(delta: float) -> void:
	if not pistol_active:
		return
		
	#vektor från spelarn till musen
	var player_pos = get_parent().global_position - Vector2(0, 10) # Vi antar att pistolen är barn till Player
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = mouse_pos - player_pos
	
	
	var max_radius = 20
	if direction_to_mouse.length() > max_radius:
		direction_to_mouse = direction_to_mouse.normalized() * max_radius #gör att den stannar vid radien 

	var target_pos = player_pos + direction_to_mouse
	global_position = global_position.lerp(target_pos, 0.1) #lerp är funktion för "linear interpolation" inbyggd. De blir snyggare så
	look_at(mouse_pos)



	if Input.is_action_just_pressed("Attack") and not is_shooting and can_shoot:
		shoot(mouse_pos)
	if is_shooting:
		bullet.global_position += (bullet_direction * bullet_velocity * delta)
	if Input.is_action_just_pressed("Reload"):
		_reload_pistol()

func shoot(target_pos: Vector2) -> void:
	handgun.show()
	bullet.show()
	bullet.set_as_top_level(true) #kulan blir oberoende av vaptnets rotation o position, kör rakt framåt
	bullet.global_position = $Gun.global_position
	bullet.set_deferred("monitoring", true) 
	bullet_direction = (target_pos - bullet.global_position).normalized()
	is_shooting = true
	Globals.ammo_in_mag -=1
	if Globals.ammo_in_mag <= 0:
		can_shoot = false
	$ResetBulletTimer.start()

func _reload_pistol() -> void:
	var after_reload = min(18 - Globals.ammo_in_mag, Globals.ammo_in_inv)
	Globals.ammo_in_mag += after_reload
	Globals.ammo_in_inv -= after_reload
	print("du har nu:", Globals.ammo_in_mag, "bullets i mag")
	if Globals.ammo_in_mag	> 0:
		can_shoot = true
func _reset_bullet() -> void:
	bullet.set_as_top_level(false) #gör att kulan blir barn t vapnet igen
	bullet.global_position = Vector2.ZERO
	bullet.hide()
	bullet.set_deferred("monitoring", false)
	is_shooting = false
	
#Anropas av Player-scriptet
func enable_weapon():
	pistol_active = true
	show()
	set_process(true)

#Anropas av Player-scriptet
func disable_weapon():
	pistol_active = false
	hide()
	set_process(false)
	_reset_bullet() # Avbryt pågående skott om man byter mitt i	


###SIGNALS####

func _on_bullet_body_entered(body: Node2D) -> void:
	if not is_shooting:
		return
	if body.is_in_group("enemies"):
		body._take_damage()
	_reset_bullet()


func _on_reset_bullet_timer_timeout() -> void:
	_reset_bullet()
