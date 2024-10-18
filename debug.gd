extends Node2D


var bounce = {
	position = Vector2(0.0, 0.0),
	velocity_in = Vector2(0.0, 0.0),
	velocity_out = Vector2(0.0, 0.0),
	normal = Vector2(0.0, 0.0)
}
const size = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	var p = bounce.position
	var vin = bounce.velocity_in.normalized() * size
	var vout = bounce.velocity_out.normalized() * size
	var n = bounce.normal.normalized() * size
	draw_line(p - vin, p, Color.WHITE, 2.0)
	draw_line(p, p + n, Color.RED, 2.0)
	draw_line(p, p + vout, Color.WHITE, 2.0)
