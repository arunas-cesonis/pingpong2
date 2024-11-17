extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

const BRICKS_W := 16
const BRICKS_H := 16
const TOP_OFFSET := 16
var brick_rect := Rect2()
var voronoi_scale := Vector2(10.0, 10.0)
var voronoi_offset := Vector2(0.0, 0.0)
var voronoi_image: Image = null

@onready var container := $Container
@onready var texture_polygon := $SubViewportContainer/SubViewport/Polygon2D
@onready var texture_subviewport: SubViewport = $SubViewportContainer/SubViewport

const SCROLL_TIME := 0.2
const SCROLL_SPAWN_TIME := 1.0
const SCROLL_WAIT := 5.0
const SMOOTH_SCROLL := false

var scroll_amount := Vector2.ZERO

func _update_voronoi_parameters() -> void:
	texture_polygon.material.set_shader_parameter("scale", voronoi_scale)
	texture_polygon.material.set_shader_parameter("offset", voronoi_offset)

func _aspect() -> float:
	var size := get_viewport_rect().size
	return size.y / size.x

func _regen_voronoi_image() -> void:
	_update_voronoi_parameters()
	if not SMOOTH_SCROLL:
		texture_subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	voronoi_image = texture_subviewport.get_texture().get_image()
	var w := BRICKS_W
	var h := ceili(_aspect() * w)
	voronoi_image.resize(w, h, Image.INTERPOLATE_NEAREST)

func _brick_position(x: int, y: int) -> Vector2:
	var bricks_width := BRICKS_W * brick_rect.size.x
	var center := Vector2(get_viewport_rect().size.x * 0.5 - bricks_width * 0.5, TOP_OFFSET)
	return brick_rect.size * Vector2(x, y) - brick_rect.position + center

func _create_brick(p: Vector2) -> Brick:
	var brick: Brick = BrickTscn.instantiate()
	brick.initial_health = 1;
	brick.position = p
	return brick

func _add_brick_checked(x: int, y: int) -> void:
	var pixel = voronoi_image.get_pixel(x, y)
	if (pixel.r + pixel.g + pixel.b) / 3.0 > 0.5:
		var p := _brick_position(x, y)
		var b := _create_brick(p)
		container.add_child(b)

func _ready_create_bricks() -> void:
	var brick: Brick = BrickTscn.instantiate()
	brick_rect = brick.get_rect()
	brick.queue_free()
	scroll_amount = Vector2(0.0, brick_rect.size.y)
	for y in range(BRICKS_H):
		for x in range(BRICKS_W):
			_add_brick_checked(x, y)

func _scroll_interval() -> void:

	# Move bricks and texture down 
	var offset_y := -voronoi_scale.y * (brick_rect.size.y / get_viewport_rect().size.y)
	create_tween().tween_property(self, "voronoi_offset", Vector2(0.0, offset_y), SCROLL_TIME).as_relative()
	for child in container.get_children():
		var brick: Brick = child
		brick.create_tween().tween_property(brick, "position", scroll_amount, SCROLL_TIME).as_relative()
	await get_tree().create_timer(SCROLL_TIME, false, true).timeout

	# Get the texture image
	await _regen_voronoi_image()

	# Spawn new bricks one-by-one
	var time_per_brick := SCROLL_SPAWN_TIME / BRICKS_W
	for x in range(BRICKS_W):
		# Exit in case this node is no longer attached (i.e. a game has ended)
		if not is_inside_tree():
			break
		await get_tree().create_timer(time_per_brick, false, true).timeout
		_add_brick_checked(x, 0)

func _ready() -> void:
	voronoi_scale.y *= _aspect()
	await _regen_voronoi_image()
	_ready_create_bricks()
	var tw := get_tree().create_tween()
	tw.tween_interval(SCROLL_WAIT)
	tw.tween_callback(_scroll_interval)
	tw.set_loops()

func _process(delta: float) -> void:
	if SMOOTH_SCROLL:
		_update_voronoi_parameters()