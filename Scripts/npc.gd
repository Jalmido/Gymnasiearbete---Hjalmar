extends CharacterBody2D
class_name NPC
###############################################################################################################################################

#### ALLT SOM FÖLJER ÄR TILL MITT GENERELLA NPC SCRIPT SOM ANVÄNDS PÅ ALLA NPCS, SOM SEDAN MODIFIERAS UTIFRÅN SPECIFIKA KRAV ########
#experimentalt frf
###############################################################################################################################################

@export var speed = 40
@export var can_roam = true
@export var dialogue_scene: PackedScene

enum{IDLE,WALK}
var state = IDLE
var dir = Vector2.ZERO
var is_busy = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var roam_timer: Timer = $RoamTimer
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	if can_roam:
		roam_timer.timeout.connect(_choose_new_state) #signal kopplas för alla npcs som ska kunna roama
		roam_timer.start()

func _physics_process(delta):
	if is_busy:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match state:
		IDLE:
			anim.play("Idle")
		WALK:
			velocity = dir * speed
			_update_animation()
	
	move_and_slide()

func _choose_new_state():
	state = [IDLE, WALK].pick_random()
	if state == WALK:
		dir = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].pick_random()

func _update_animation():
	if abs(dir.x) > abs(dir.y):
		anim.play("Walk_side")
		anim.flip_h = dir.x > 0
	elif dir.y < 0:
		anim.play("Walk_up")
	else:
		anim.play("Walk_down")

func _on_interact():
	if is_busy:
		return

	if dialogue_scene:
		is_busy = true
		var dialogue = dialogue_scene.instantiate()
		get_tree().current_scene.add_child(dialogue)
		dialogue.start()
		dialogue.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished():
	is_busy = false
