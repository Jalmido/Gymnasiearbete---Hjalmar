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
		
	if bullet.global_position.length() > 1200:
			_reset_bullet()

func shoot(target_pos: Vector2) -> void:
	bullet.global_position = $Gun.global_position
	handgun.show()
	$ShowGunTimer.start()
	bullet.show()

	bullet_direction = (target_pos - bullet.global_position).normalized()
	is_shooting = true
	
	

func _reset_bullet() -> void:
	bullet.global_position = Vector2.ZERO
	bullet.hide()

	is_shooting = false
	


func _on_bullet_body_entered(body: Node2D) -> void:
	_reset_bullet()
	


func _on_timer_timeout() -> void:
	handgun.hide()
