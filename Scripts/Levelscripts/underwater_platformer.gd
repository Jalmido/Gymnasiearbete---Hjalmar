extends Node2D
 
var boss_alive = true

@export var level_music: AudioStream

func _ready() -> void:
	"
	Checkpoint sparas
	"
	Globals.save_checkpoint()

func _on_fight_activation_area_body_entered(body: Node2D) -> void:
	"
	Om man går in i bossrummets activation_area så stängs väggarna runt boss rummet och bossmusiken startar, samt bossen slås igång
	"
	if boss_alive:
		MusicManager.play_track(level_music)
		$Boss_Arena_doors.enabled = true	
		$Boss/Executioner_boss.active = true
	
