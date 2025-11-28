extends Node2D

var mouseposition
var bullet_velocity = 2000
var is_shooting = false
var bullet_direction = Vector2.ZERO



@onready var bullet: Area2D = $Bullet
@onready var handgun: Node2D = $"."

func _process(delta: float) -> void:
	mouseposition = get_global_mouse_position()
	
	look_at(mouseposition)
	if Input.is_action_just_pressed("Shoot") and not is_shooting:
		shoot(mouseposition)
	
	if is_shooting:
		bullet.global_position += (bullet_direction * bullet_velocity * delta)
		


func shoot(target_pos: Vector2) -> void:
	handgun.show()
	$ShowGunTimer.start()
	bullet.show()
	bullet.set_as_top_level(true) #kulan blir oberoende av vaptnets rotation o position, kör rakt framåt
	bullet.global_position = $Gun.global_position
	bullet.set_deferred("monitoring", true) 
	bullet_direction = (target_pos - bullet.global_position).normalized()
	is_shooting = true
	$ResetBulletTimer.start()
	

func _reset_bullet() -> void:
	bullet.set_as_top_level(false) #gör att kulan blir barn t vapnet igen
	bullet.global_position = Vector2.ZERO
	bullet.hide()
	bullet.set_deferred("monitoring", false)
	is_shooting = false
	
###SIGNALS####

func _on_bullet_body_entered(body: Node2D) -> void:
	if not is_shooting:
		return
	if body is Enemy:
		body._take_damage()
	_reset_bullet()
	
func _on_timer_timeout() -> void:
	handgun.hide()


func _on_reset_bullet_timer_timeout() -> void:
	_reset_bullet()
