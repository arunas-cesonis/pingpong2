extends Node2D

# TODO
# 1. On-collision properties: angle limit, acceleration, node spawned, sound played.
# Use @export_exp_easing where applicable.
# 2. Mouse controls

const Brick = preload("res://brick.gd")
const RotatingBrick = preload("res://rotating_brick.gd")

@onready var player: AnimatableBody2D = $Player
@onready var ball: AnimatableBody2D = $Ball
@onready var bricks: Node2D = $Bricks
@onready var debug: Node2D = $Debug

@export_group("Common")
@export var initial_ball_direction := Vector2(0.0, 1.0)
@export var initial_ball_speed := 500.0
@export var player_speed := 500.0
@export var reflect_amount := 0.5

@export_group("Ball collision")
@export_category("Wall")
@export var wall_angle_limit := 180.0
@export var wall_acceleration := 0.0
@export var wall_spawn_node: PackedScene = null
@export_category("Player")
@export var player_angle_limit := 180.0
@export var player_acceleration := 0.0
@export var player_spawn_node: PackedScene = null
@export_category("Brick")
@export var brick_angle_limit := 180.0
@export var brick_acceleration := 0.0
@export var brick_spawn_node: PackedScene = null

@onready var player_velocity = Vector2.ZERO

var score := 0

@onready var ball_speed = initial_ball_speed
@onready var ball_direction = initial_ball_direction

signal finished(score: int)

func brick_remaining() -> int:
	return bricks.get_child_count()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _ball_velocity() -> Vector2:
	return ball_direction * ball_speed

func _limit_bounce_angle(normal: Vector2, direction: Vector2, limit: float) -> Vector2:
	var angle = normal.angle_to(direction)
	var new_angle = signf(angle) * minf(abs(angle), deg_to_rad(limit))
	return Vector2.from_angle(normal.angle() + new_angle)

func _physics_process(delta: float) -> void:
	player.move_and_collide(player_velocity * delta)

	# safe_margin = 1.0 here helps to unstuck the ball from rotating platforms
	# and possibly player controlled platform
	var safe_margin := 1.0
	var collision = ball.move_and_collide(_ball_velocity() * delta,
		false, safe_margin)
	if collision:
		var normal: Vector2 = collision.get_normal()
		var bounce_angle_limit := 0.0
		if collision.get_collider() == player:
			var offset := player.position.x - collision.get_position().x
			var shape: RectangleShape2D = player.get_child(0).shape
			var offset_normalized := offset / shape.size.x
			var angle_adjustment := offset_normalized * reflect_amount
			var normal_offseted := Vector2.from_angle(normal.angle() - angle_adjustment)
			normal = normal_offseted
			bounce_angle_limit = player_angle_limit
		elif collision.get_collider() is Brick:
			var brick := collision.get_collider() as Brick
			if brick.apply_damage(101.0):
				score += 1
			bounce_angle_limit = brick_angle_limit
		else:
			bounce_angle_limit = wall_angle_limit

		$Debug.bounce.velocity_in = _ball_velocity()
		ball_direction = ball_direction.bounce(normal).normalized()
		$Debug.bounce.velocity_out_unlimited = _ball_velocity()
		ball_direction = _limit_bounce_angle(normal, ball_direction, bounce_angle_limit)
		$Debug.bounce.velocity_out = _ball_velocity()
		$Debug.bounce.position = collision.get_position()
		$Debug.bounce.normal = normal
		$Debug.queue_redraw()

	if ball.position.y > player.position.y or bricks.get_child_count() == 0:
		finished.emit(score)

func _process(_delta: float) -> void:
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	player_velocity.x = direction * player_speed
	$Debug.update_value("score", score)
	$Debug.update_value("bricks.get_child_count()", bricks.get_child_count())
