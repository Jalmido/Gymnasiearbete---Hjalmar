extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var boss_select: Panel = $"Boss Select"


func _ready() -> void:
	#get_node("VBoxContainer/Start_button").grab_focus()
	$AnimatedSprite2D.play("Idle")
	v_box_container.visible = true
	boss_select.visible = false
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/overworld.tscn")
	_set_story_mode_values()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_boss_battles_pressed() -> void:
	v_box_container.visible = false
	boss_select.visible = true
	
	
	

func _set_story_mode_values():
	Globals.lives = 4
	Globals.ammo_in_mag = 8
	Globals.ammo_in_inv = 12
	Globals.boss_fight_mode = false

func _set_boss_mode_values():
	Globals.lives = 4
	Globals.ammo_in_mag = 4
	Globals.ammo_in_inv = 8
	Globals.boss_fight_mode = true

#### BOSS FIGHTS ####

func _on_rock_golem_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Underground/underground_room_2.tscn")
	_set_boss_mode_values()

func _on_executioner_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/underwater_platformer.tscn")
	_set_boss_mode_values()

func _on_elder_soren_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Yunion/the_yunion.tscn")
	_set_boss_mode_values()

func _on_back_pressed() -> void:
	_ready()
