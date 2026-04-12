extends CharacterBody2D

const SPEED = 300

var bounces_left = 20
var direction = Vector2.ZERO
var shoot_out = false
var has_been_summoned = false
var summon_setup_finished = false

@onready var path: Line2D = $Path_line
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	"
	Körs hela tiden. Kontrollerar när summonen blir summoned och när han blir det av bossen (när bossen blir 10 hp),
	så anropas summoned() funktionen och summonen skjuts ut. Från _summoned() får varje summon en slumpad riktning att skjuta ut
	Och när den studsar i väggen och den har bounces kvar, så reflekterar den. När den når 0 bounces spelas dödsanimation och den försvinner
	"
	if not has_been_summoned:
		return
	elif has_been_summoned and not summon_setup_finished:
		_summoned()

	if not shoot_out:
		return
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if bounces_left > 0:
			#Räkna ut reflektionsvinkeln mot väggen
			velocity = velocity.bounce(collision.get_normal())
			bounces_left -= 1
		else:
			anim.play("Death")
			queue_free()

func _summoned(): 
	"
	Setar upp summons, och slumpar vinklar och slår på hitboxes så de kan skada fiende. Definierar velocityn som den skjuts ut i.
	"
	
	$Shoot_out_timer.start()
	anim.play("Summoned")
	
	var angle = randf_range(0,2*PI)
	direction = Vector2.UP.rotated(angle)
	velocity = direction * SPEED
	
	$Area2D.set_deferred("monitoring", true)
	visible = true
	
	summon_setup_finished = true

func _on_shoot_out_timer_timeout() -> void: 
	"
	Skjuter ut när timer är klar
	"
	shoot_out = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	"
	Skadar spelaren vid kollision
	"
	if body.is_in_group("player"):
		body._take_damage(1)
	
