extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

var brick_size: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var top_left := Vector2(INF, INF)
	for child in self.get_children():
		if child is Brick:
			break
	for child in self.get_children():
		if child is Brick:
			var brick: Brick = child
			top_left.x = minf(top_left.x, brick.position.x)
			top_left.y = minf(top_left.y, brick.position.y)
			if brick_size.is_zero_approx():
				brick_size = brick.get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
