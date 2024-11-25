extends StaticBody2D

var alive: bool = true
var attached: bool = false

func get_rect() -> Rect2:
	return $CollisionShape2D.shape.get_rect()

func apply_damage(_amount: int) -> bool:
	if alive:
		queue_free()
		alive = false
		return true
	return false

func _process(_delta: float) -> void:
	if not attached:
		modulate.r = 0.0
	else:
		modulate.r = 1.0