extends CharacterBody2D

@export var max_health: int = 100
@export var invulnerability_time: float = 1.5

signal health_changed(current_health: int, max_health: int)
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var health: int
var is_invulnerable := false

@export var speed: float = 300.0

enum Depth {
	SURFACE,
	UNDERWATER
}

var depth: Depth = Depth.SURFACE

@onready var body: Polygon2D = $body

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("dive"):
		toggle_depth()

func is_underwater() -> bool:
	return depth == Depth.UNDERWATER

func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return

	health = max(health - amount, 0)

	health_changed.emit(health, max_health)

	if hit_sound.stream:
		hit_sound.play()

	flash_damage()
	start_invulnerability()

	if health <= 0:
		die()

func flash_damage() -> void:
	body.modulate = Color.RED

	await get_tree().create_timer(0.12).timeout

	if depth == Depth.UNDERWATER:
		body.modulate = Color(0.5, 0.5, 0.8, 0.45)
	else:
		body.modulate = Color.WHITE

func start_invulnerability() -> void:
	is_invulnerable = true

	await get_tree().create_timer(invulnerability_time).timeout

	is_invulnerable = false

func die() -> void:
			print("KRAKEN DIED")
			set_physics_process(false)

func toggle_depth() -> void:
	if depth == Depth.SURFACE:
		depth = Depth.UNDERWATER

		collision_layer = 2
		collision_mask = 2

		body.modulate = Color(0.5, 0.5, 0.8, 0.45)
		print("UNDERWATER")
	else:
		depth = Depth.SURFACE

		collision_layer = 1
		collision_mask = 1

		body.modulate = Color(1.0, 1.0, 1.0, 1.0)
		print("SURFACE")
