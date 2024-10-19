extends AnimatableBody2D

func _physics_process(delta: float) -> void:
	rotation += delta * 4.0
