extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

var bricks_w := 4
var bricks_h := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rect := Rect2()
	for y in range(bricks_h):
		for x in range(bricks_w):
			var brick: Brick = BrickTscn.instantiate()
			if rect.size.is_zero_approx():
				rect = brick.get_rect()
			brick.position = rect.position * -1.0 + rect.size * Vector2(x, y)
			add_child(brick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
