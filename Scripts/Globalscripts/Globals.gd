extends Node

signal lives_changed(new_health) #När liv ändras, anvädns denna för att ändra healthbar.
signal victory_screen_requested #Används om man kör boss fight mode ist för story mode, då triggas en victory screen vid vinst


var miniboss_room_cleared = false #så bossrummet inte restartar om man går tillbaka efter att man dödat dene.

var visited_scenes = [] #här hamnar scener som varit activa, ifall en cutscene eller så ska spelas bara första gången man aktiverar
var picked_up_items = [] #för att förhindra "duplicering" av items

var objective_recieved = false #Prata m Soren i början för objective, då kan man hoppa i abyss
var yunion_key_collected = false #Om true, läggs den i hotbar
var boss_fight_mode = false #Används om man inte kör storyn, och bara bossfights, och ger då en victory screen när boss dör.
var boss_room = false
var ammo_in_mag: int = 18
var ammo_in_inv: int = 8 
var health_potions_in_inv = 0
var saved_position: Vector2
var lives: int = 4:
	set(value):
		lives = value
		emit_signal("lives_changed", lives)

var checkpoint_data = {}

func save_checkpoint(): #Början av varje rum/scen sparar ett "checkpoint" som berättar hur mkt av olika items och så man hade i början av scenen, så om man dör loadas detta om man restartar från checkpoint
	checkpoint_data = {
		"lives": lives,
		"ammo_in_mag": ammo_in_mag,
		"ammo_in_inv": ammo_in_inv,
		"health_potions": health_potions_in_inv,
		"picked_up_items": picked_up_items.duplicate()
	}


func load_checkpoint(): #När man loadar ändras ens items och grejer till det som sparades i save checkpoint
	if checkpoint_data.is_empty():
		return 
	
	lives = checkpoint_data["lives"] if not boss_room else 4 #om man är i boss fight rum, respawnar man m max hp
	ammo_in_mag = checkpoint_data["ammo_in_mag"]
	ammo_in_inv = checkpoint_data["ammo_in_inv"]
	health_potions_in_inv = checkpoint_data["health_potions"]
	picked_up_items = checkpoint_data["picked_up_items"].duplicate()
