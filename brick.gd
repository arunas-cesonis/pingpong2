extends StaticBody2D

@export_range(1, 3) var initial_health := 3
@onready var health := initial_health
@onready var start_position := position

enum Status {OK, DAMAGED, DEAD}

var status: Status = Status.OK
var tween: Tween = null
var attached: bool = false
var velocity: Vector2 = Vector2.ZERO

var UNHEALTHY: Color = Color.hex(0xc8d627ff)
var HEALTHY: Color = Color.WHITE

func _update_health_visuals() -> void:
	var mod := UNHEALTHY.lerp(HEALTHY, float(health) / initial_health)
	$Sprite2D.modulate = mod
	if health < initial_health:
		$Sprite2D.frame = 10

func is_dead() -> bool:
	return get_status() == Status.DEAD

func get_rect() -> Rect2:
	return $CollisionShape2D.shape.get_rect()

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
	if self.get_status() == Status.DEAD and prev_status != Status.DEAD:
		self.queue_free()
		return true
	return false

func _ready() -> void:
	# self.modulate.a = 0.0
	# create_tween().tween_property(self, "modulate:a", 1.0, 0.2)
	_update_health_visuals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	return
	if not attached:
		modulate.r = 0.0
	else:
		modulate.r = 1.0