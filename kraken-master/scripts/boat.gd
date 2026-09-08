extends CharacterBody2D

@export var speed: float = 170.0
@export var turn_speed: float = 2.5
@export var target_path: NodePath
@export var collision_damage: int = 10

@onready var target = get_node(target_path)

var last_known_position := Vector2.ZERO

func _ready() -> void:
	last_known_position = target.global_position


func _physics_process(delta: float) -> void:
	if target == null:
		return

	if not target.is_underwater():
		last_known_position = target.global_position

	var to_target := last_known_position - global_position

	if to_target.length() < 10.0:
		velocity = Vector2.ZERO
		return

	var desired_angle := to_target.angle()

	rotation = lerp_angle(
		rotation,
		desired_angle,
		turn_speed * delta
	)

	velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == target:
			if collider.has_method("take_damage"):
				collider.take_damage(collision_damage)
