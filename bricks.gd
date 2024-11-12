extends Node2D

const BrickTscn = preload("res://brick.tscn")
const Brick = preload("res://brick.gd")
const GenTexture = preload("res://gen_texture.png") 

var bricks_w := 16
var bricks_h := 16
var top_offset := 16
var brick_rect := Rect2()
var image := GenTexture.get_image()

const SCROLL_TIME := 0.2
const SCROLL_SPAWN_TIME := 1.0
const SCROLL_WAIT := 2.0

var scroll_amount := Vector2.ZERO

func _init() -> void:
	image.resize(bricks_w, bricks_h, Image.INTERPOLATE_NEAREST)

func _create_brick(x: int, y: int) -> Brick:
	var bricks_width := bricks_w * brick_rect.size.x
	var center := Vector2(get_viewport_rect().size.x * 0.5 - bricks_width * 0.5, top_offset)
	var brick: Brick = BrickTscn.instantiate()
	brick.initial_health = 1;
	brick.position = brick_rect.size * Vector2(x, y) - brick_rect.position + center
	return brick

func _create_bricks() -> void:
	var brick: Brick = BrickTscn.instantiate()
	brick_rect = brick.get_rect()
	brick.queue_free()
	scroll_amount = Vector2(0.0, brick_rect.size.y)
	for y in range(bricks_h):
		for x in range(bricks_w):
			var pixel := image.get_pixel(x, y)
			if pixel != Color.BLACK:
				add_child(_create_brick(x, y))

func _scroll_interval() -> void:
	for child in get_children():
		var brick: Brick = child
		brick.create_tween().tween_property(brick, "position", scroll_amount, SCROLL_TIME).as_relative()
	await get_tree().create_timer(SCROLL_TIME, false, true).timeout
	var time_per_brick := SCROLL_SPAWN_TIME / bricks_w
	for x in range(bricks_w):
		# Exit in case this node is no longer attached (i.e. a game has ended)
		if not is_inside_tree():
			break
		await get_tree().create_timer(time_per_brick, false, true).timeout
		add_child(_create_brick(x, 0))

func _ready() -> void:
	_create_bricks()
	var tw := get_tree().create_tween()
	tw.tween_interval(SCROLL_WAIT)
	tw.tween_callback(_scroll_interval)
	tw.set_loops()