extends CharacterBody2D

const SPEED = 300

var bounces_left = 2
var direction = Vector2.ZERO
var shoot_out = false

@onready var path: Line2D = $Path_line
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	$Shoot_out_timer.start()
	var angle = randf_range(0,2*PI)
	direction = Vector2.UP.rotated(angle)
	velocity = direction * SPEED

	_draw_path()

func _process(delta: float) -> void:
	if not shoot_out:
		return
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if bounces_left > 0:
			# Räkna ut reflektionsvinkeln mot väggen
			velocity = velocity.bounce(collision.get_normal())
			bounces_left -= 1
		else:
			anim.play("Death")
			queue_free()

func _draw_path():

	path.clear_points()
	path.add_point(Vector2.ZERO) # Startpunkt (lokal)
	
	var current_pos = Vector2.ZERO
	var current_dir = direction * 1000 # Lång räckvidd för sökning
	var temp_bounces = 2
	
	# Vi använder en RayCast eller direkt i koden med SpaceState för att hitta väggar
	var space_state = get_world_2d().direct_space_state
	
	while temp_bounces >= 0:
		var query = PhysicsRayQueryParameters2D.create(global_position + current_pos, global_position + current_pos + current_dir)
		query.exclude = [get_rid()] # Ignorera summonen själv
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_pos = to_local(result.position)
			path.add_point(hit_pos)
			
			# Beräkna nästa riktning för linjen
			var normal = result.normal
			current_dir = current_dir.bounce(normal)
			current_pos = hit_pos
			temp_bounces -= 1
		else:
			# Om ingen vägg träffas, rita bara linjen ut i intet
			path.add_point(to_local(global_position + current_dir))
			break


func _on_shoot_out_timer_timeout() -> void:
	print("shoot out")
	shoot_out = true
