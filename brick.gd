extends StaticBody2D

@onready var health_label = $Health
@export var initial_health := 100.0
@onready var health := initial_health

enum Status {OK, DAMAGED, DEAD}
var status: Status = Status.OK

func _update_text() -> void:
	health_label.text = str(health)

func is_dead() -> bool:
	return get_status() == Status.DEAD

func get_status() -> Status:
	if health < initial_health:
		if health > 0.0:
			return Status.DAMAGED
		else:
			return Status.DEAD
	else:
		return Status.OK

func apply_damage(amount: float) -> bool:
	var prev_status := self.get_status()
	health -= amount
	_update_text()
	if self.get_status() == Status.DEAD:
		self.queue_free()
		return prev_status != Status.DEAD
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
