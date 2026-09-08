extends CanvasLayer

@export var kraken_path: NodePath

@onready var kraken = get_node(kraken_path)
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	health_bar.max_value = kraken.max_health
	health_bar.value = kraken.health

	kraken.health_changed.connect(_on_health_changed)


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
