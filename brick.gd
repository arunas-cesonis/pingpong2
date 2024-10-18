extends StaticBody2D

@onready var health_label = $Health
@export var initial_health := 100.0
@onready var health := initial_health

func apply_damage(amount: float) -> void:
	health -= amount
	health_label.text = str(health)
	if health <= 0.0:
		self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
