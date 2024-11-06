extends StaticBody2D

@export_range(1, 3) var initial_health := 3
@onready var health := initial_health

enum Status {OK, DAMAGED, DEAD}
var status: Status = Status.OK

func _update_health_visuals() -> void:
	$DemoBrick.set_frame_and_progress(health-1, 0.0)

func is_dead() -> bool:
	return get_status() == Status.DEAD

func get_status() -> Status:
	if health < initial_health:
		if health > 0:
			return Status.DAMAGED
		else:
			return Status.DEAD
	else:
		return Status.OK

func apply_damage(amount: int) -> bool:
	var prev_status := self.get_status()
	health -= amount
	_update_health_visuals()
	if self.get_status() == Status.DEAD:
		self.queue_free()
		return prev_status != Status.DEAD
	return false

func _ready() -> void:
	_update_health_visuals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
