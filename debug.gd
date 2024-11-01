extends Node2D


var bounce = {
	position = Vector2(0.0, 0.0),
	velocity_in = Vector2(0.0, 0.0),
	velocity_out = Vector2(0.0, 0.0),
	normal = Vector2(0.0, 0.0)
}
var values = {}
const size = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_value(key: String, value: Variant) -> void:
	if not key in values or values[key] != value:
		queue_redraw()
	values[key] = value

func _draw():
	# reflection
	var p = bounce.position
	var vin = bounce.velocity_in.normalized() * size
	var vout = bounce.velocity_out.normalized() * size
	var n = bounce.normal.normalized() * size
	draw_line(p - vin, p, Color.WHITE, 2.0)
	draw_line(p, p + n, Color.RED, 2.0)
	draw_line(p, p + vout, Color.WHITE, 2.0)
	# values
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	var h = 32.0
	for k in values:
		draw_string(default_font, Vector2(32.0, h), k + ": " + str(values[k]), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)
		h = h + 24.0
