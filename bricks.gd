extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")

const BRICKS_W := 16
const BRICKS_H := 29
const BRICKS_INIT_H := 16
var brick_rect := Rect2()
var voronoi_scale := Vector2(10.0, 10.0)
var voronoi_offset := Vector2(0.0, 0.0)
var voronoi_image: Image = null

@onready var container := $Container
@onready var free_container := $FreeContainer
@onready var texture_polygon := $SubViewportContainer/SubViewport/Polygon2D
@onready var texture_subviewport: SubViewport = $SubViewportContainer/SubViewport

const SCROLL_TIME := 0.2
const SCROLL_SPAWN_TIME := 1.0
const SCROLL_WAIT := 4.0
const SMOOTH_SCROLL := false

var scroll_amount := Vector2.ZERO
var scrolling := false

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
	voronoi_image.resize(BRICKS_W, BRICKS_H, Image.INTERPOLATE_NEAREST)

func _brick_position(x: int, y: int) -> Vector2:
	return brick_rect.size * Vector2(x, y) - brick_rect.position

func _create_brick(p: Vector2) -> Brick:
	var brick: Brick = BrickTscn.instantiate()
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
	for y in range(BRICKS_INIT_H):
		for x in range(BRICKS_W):
			_add_brick_checked(x, y)

func _scroll_iter() -> bool:
	# Wait
	if not is_inside_tree():
		return false
	await get_tree().create_timer(SCROLL_WAIT, false, true).timeout

	# Move bricks and texture down 
	var offset_y := -voronoi_scale.y * (brick_rect.size.y / get_viewport_rect().size.y)
	create_tween().tween_property(self, "voronoi_offset", Vector2(0.0, offset_y), SCROLL_TIME).as_relative()
	for child in container.get_children():
		var brick: Brick = child
		if not brick.attached:
			continue
		var tween := brick.create_tween()
		tween.tween_property(brick, "position", scroll_amount, SCROLL_TIME).as_relative()

	if not is_inside_tree():
		return false
	await get_tree().create_timer(SCROLL_TIME, false, true).timeout

	# Fetch the texture image
	await _regen_voronoi_image()
	if not is_inside_tree():
		return false

	# Spawn new bricks one-by-one
	for x in range(BRICKS_W):
		_add_brick_checked(x, 0)

	return true

func _scroll_loop() -> void:
	while await _scroll_iter():
		pass

func _ready() -> void:
	voronoi_scale.y *= _aspect()
	await _regen_voronoi_image()
	_ready_create_bricks()
	_scroll_loop()

func _in_bounds(v: Vector2i) -> bool:
	return v.x >= 0 and v.y >= 0 and v.x < BRICKS_W and v.y < BRICKS_H 

var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

func _physics_process(_delta: float) -> void:
	_run_bricks()

func _brick_grid_pos(pos: Vector2) -> Vector2i:
	var x := floori(pos.x / brick_rect.size.x)
	var y := floori(pos.y / brick_rect.size.y)
	return Vector2i(x, y)
 
func _run_bricks() -> void:
	var bricks: Array[Array] = []
	bricks.resize(BRICKS_H)
	for y in range(bricks.size()):
		bricks[y].resize(BRICKS_W)
		bricks[y].fill(null)

	for child in container.get_children():
		var b: Brick = child 
		var gp := _brick_grid_pos(b.position) 
		var x := gp.x
		var y := gp.y
		if y >= BRICKS_H:
			b.queue_free()
			continue
		assert(bricks[y][x] == null)
		b.attached = false
		bricks[y][x] = b

	var stack: Array[Vector2i] = []
	for y in range(0, 2):
		for x in range(BRICKS_W):
			if bricks[y][x]:
				bricks[y][x].attached = x + 1
				stack.push_back(Vector2i(x, y))

	while stack:
		var xy: Vector2i = stack.pop_back()  
		for d in directions:
			var next := xy + d
			if not _in_bounds(next):
				continue
			var b: Brick = bricks[next.y][next.x]
			if b and not b.attached:
				b.attached = true
				stack.push_back(next)

func _process(_delta: float) -> void:
	if SMOOTH_SCROLL:
		_update_voronoi_parameters()