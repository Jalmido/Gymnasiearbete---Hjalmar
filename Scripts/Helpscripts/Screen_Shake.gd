extends Camera2D



var shake_strength: float = 0.0
var active_shake_time: float = 0.0
var shake_decay: float = 5.0
var shake_time: float = 0.0
var shake_time_speed: float = 20.0
var noise = FastNoiseLite.new()

func _physics_process(delta: float) -> void:
	"
	Hanterar skaklogiken för varje frame. Om tid finns kvar genereras en sllumpad förflyttning av kameran (FastNoiseLite)
	Annar mjukas kamerans position tillbaka till ursprungspositionen med lerp. 
	"
	if active_shake_time > 0: 
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		offset = Vector2(noise.get_noise_2d(shake_time, 0) * shake_strength, noise.get_noise_2d(0, shake_time) * shake_strength)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)
		
func _screen_shake(intensity: int, time: float):
	"
	Shake-effekten startas genom att slumpa ett seed och ställa in hur kraftigt och länge shaken ska hålla på
	noise används för att skapa lite mer smooth skak, ist för att kameran ska tp:a runt.
	"
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	shake_strength = intensity
	active_shake_time = time
	shake_time = 0.0
