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
@export_category("Player")
@export_range(0.0, 90.0, 0.001, "degrees") var player_angle_limit_min := 0.0
@export_range(0.0, 90.0, 0.001, "degrees") var player_angle_limit_max := 90.0
@export var curve_demo: Curve = Curve.new()
@export_category("Wall")
@export_range(0.0, 90.0, 0.001, "degrees") var wall_angle_limit_min := 0.0
@export_range(0.0, 90.0, 0.001, "degrees") var wall_angle_limit_max := 90.0
@export_category("Brick")
@export_range(0.0, 90.0, 0.001, "degrees") var brick_angle_limit_min := 0.0
@export_range(0.0, 90.0, 0.001, "degrees") var brick_angle_limit_max := 90.0

@onready var player_velocity = Vector2.ZERO

var score := 0
var ball_speed_tween: Tween = null

@onready var ball_speed = initial_ball_speed
@onready var ball_direction = initial_ball_direction

signal finished(score: int)

func brick_remaining() -> int:
	return bricks.get_child_count()

func _ready() -> void:
	pass

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _ball_velocity() -> Vector2:
	return ball_direction * ball_speed

func _limit_bounce_angle(normal: Vector2, direction: Vector2, limit_min: float, limit_max: float) -> Vector2:
	var angle = normal.angle_to(direction)
	var new_angle = signf(angle) * clampf(absf(angle), limit_min, limit_max)
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
		var bounce_angle_limit_min := 0.0
		var bounce_angle_limit_max := 90.0
		if collision.get_collider() == player:
			var offset := player.position.x - collision.get_position().x
			var shape: RectangleShape2D = player.get_child(0).shape
			var offset_normalized := offset / shape.size.x
			var angle_adjustment := offset_normalized * reflect_amount
			var normal_offseted := Vector2.from_angle(normal.angle() - angle_adjustment)
			normal = normal_offseted
			bounce_angle_limit_max = player_angle_limit_max
			bounce_angle_limit_min = player_angle_limit_min

			if ball_speed_tween:
				ball_speed_tween.kill()
				ball_speed_tween = null
			var tween := get_tree().create_tween()
			ball_speed = 1000.0
			tween.set_parallel(true)
			var t = tween.tween_property(self, "ball_speed", initial_ball_speed, 3.0)
			t.set_ease(Tween.EaseType.EASE_OUT)
			t.set_trans(Tween.TransitionType.TRANS_QUAD)
			ball_speed_tween = tween

		elif collision.get_collider() is Brick:
			var brick := collision.get_collider() as Brick
			if brick.apply_damage(101.0):
				score += 1
			bounce_angle_limit_min = brick_angle_limit_min
			bounce_angle_limit_max = brick_angle_limit_max
		else:
			bounce_angle_limit_min = wall_angle_limit_min
			bounce_angle_limit_max = wall_angle_limit_max

		bounce_angle_limit_min = deg_to_rad(bounce_angle_limit_min)
		bounce_angle_limit_max = deg_to_rad(bounce_angle_limit_max)

		$Debug.bounce.velocity_in = _ball_velocity()
		ball_direction = ball_direction.bounce(normal).normalized()
		$Debug.bounce.velocity_out_unlimited = _ball_velocity()
		ball_direction = _limit_bounce_angle(normal, ball_direction, bounce_angle_limit_min, bounce_angle_limit_max)
		$Debug.bounce.velocity_out = _ball_velocity()
		$Debug.bounce.angle_min = bounce_angle_limit_min
		$Debug.bounce.angle_max = bounce_angle_limit_max
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
	$Debug.update_value("ball_speed", ball_speed)
