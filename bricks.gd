extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

var bricks_w := 16
var bricks_h := 16
var top_offset := 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var brick: Brick = BrickTscn.instantiate()
	var brick_rect := brick.get_rect()
	var bricks_width := bricks_w * brick_rect.size.x
	var center := Vector2(get_viewport_rect().size.x * 0.5 - bricks_width * 0.5, top_offset)
	for y in range(bricks_h):
		for x in range(bricks_w):
			brick = BrickTscn.instantiate() if not brick else brick
			brick.position = brick_rect.size * Vector2(x, y) - brick_rect.position + center
			add_child(brick)
			brick = null
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
