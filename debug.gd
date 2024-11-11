extends Node2D


var bounce = {
	position = Vector2(0.0, 0.0),
	velocity_in = Vector2(0.0, 0.0),
	velocity_out = Vector2(0.0, 0.0),
	velocity_out_unlimited = Vector2(0.0, 0.0),
	normal = Vector2(0.0, 0.0),
	angle_min = 0.0,
	angle_max = 0.0,
}

var influence = {
	ball = Vector2.ZERO,
	player = Vector2.ZERO,
	min_distance = 0.0,
	max_distance = 0.0,
}

var values = {}
const BOUNCE_SIZE := 100.0

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

func _draw_text(s: String, pos: Vector2) -> void:
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	var size = default_font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)
	# draw_rect(Rect2(pos - Vector2(0.0, size.y), size), Color(1.0, 1.0, 1.0, 0.5), true, 0.0)
	var vp := get_viewport_rect().size
	var pos_l = Vector2(minf(pos.x, vp.x - size.x), minf(pos.y, vp.y - size.y))
	draw_string(default_font, pos_l, s, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

func _draw_bounce(b: Dictionary) -> void:
	if b.velocity_in.is_zero_approx():
		return
	var p = b.position
	var vin = b.velocity_in.normalized() * BOUNCE_SIZE
	var vout = b.velocity_out.normalized() * BOUNCE_SIZE
	var voutu = b.velocity_out_unlimited.normalized() * BOUNCE_SIZE
	var n = b.normal.normalized() * BOUNCE_SIZE
	var angle = b.normal.angle_to(b.velocity_out)
	var angle_u = b.normal.angle_to(b.velocity_out_unlimited)

	# draw_arc(p, BOUNCE_SIZE * 0.5, b.normal.angle() + b.angle_min, b.normal.angle() + b.angle_max, 20, Color(0.0, 1.0, 0.0, 0.5), 10.0)

	draw_line(p - vin, p, Color.WHITE, 2.0)
	draw_line(p, p + n, Color.RED, 2.0)
	draw_line(p, p + voutu, Color.WHITE, 2.0)
	draw_dashed_line(p, p + vout, Color.WHITE, 2.0, 5.0, false)
	if angle_u != angle:
		_draw_text("%.2f -> %.2f" % [rad_to_deg(angle_u), rad_to_deg(angle)], p + vout)
	else:
		_draw_text("%.2f" % [rad_to_deg(angle_u)], p + vout)

func _draw_influence(d: Dictionary) -> void:
	var player: Vector2 = d.player
	var ball: Vector2 = d.ball
	var min_distance: float = d.min_distance
	var max_distance: float = d.max_distance
	var distance := absf(player.y - ball.y)
	if distance <= max_distance and distance >= min_distance:
		var a := Vector2(0.0, player.y - max_distance)
		var b := Vector2(1080.0, player.y - max_distance)
		draw_dashed_line(a, b, Color.WHITE, 2.0, 5.0, false)
		a = Vector2(0.0, player.y - min_distance)
		b = Vector2(1080.0, player.y - min_distance)
		draw_dashed_line(a, b, Color.WHITE, 2.0, 5.0, false)

func _draw():
	# bounce
	_draw_bounce(bounce)
	_draw_influence(influence)
	# values
	var h := 32.0
	for k in values:
		var s = k + ": " + str(values[k])
		var pos := Vector2(32.0, h)
		_draw_text(s, pos)
		h = h + 24.0
