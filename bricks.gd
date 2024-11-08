extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in get_children():
		var b: Brick = p

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
