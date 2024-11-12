extends Node2D

# TODO
# 1. DONE. Restrict reflection normal from player pad to Vector2.UP
# 2. DONE. 3 states for bricks.
# 3. DONE. Spawn nodes on collision
# 4. DONE. Bricks spawn on timer and scroll down. Generated grid, scrolls down.
# 5. DONE. When ball is close to pad and F is pressed, extra boost is applied. 3 seperate influence zones.
# 6. Make player reflection angle like in DX-BALL
# 7. Mouse controls
# 8. Bricks that do not touch should fall down.
# 9. Sound

const Brick = preload("res://brick.gd")
const BrickTscn = preload("res://brick.tscn")
const RotatingBrick = preload("res://rotating_brick.gd")

const CollisionSound = preload("res://sounds/collision.wav")
const Collision2Sound = preload("res://sounds/collision2.wav")
const DestroySound = preload("res://sounds/destroy.wav")

@onready var player: AnimatableBody2D = $Player
@onready var player_collision_shape: RectangleShape2D = player.find_child("CollisionShape2D", false).shape
@onready var ball: AnimatableBody2D = $Ball
@onready var debug: Node2D = $Debug

@export_group("Common")

@export_range(0.0, 200.0) var influence_min_distance := 20.0
@export_range(0.0, 200.0) var influence_max_distance := 200.0
@export var influence_curve: Curve = Curve.new()
@export_range(0.0, 10.0, 0.001) var influence_duration: float = 1.0
@onready var influence_time := influence_duration

enum InfluenceState {TOO_FAR, USED, AVAILABLE}
var influence_state: InfluenceState = InfluenceState.TOO_FAR

@export var initial_ball_direction := Vector2(0.0, 1.0)
@export var player_speed := 500.0
@export var reflect_amount := 1.0
@export var spawn_on_collision: PackedScene = null
@export_category("Ball speed")
@export var base_ball_speed := 500.0

@export var ball_speed_player_collision: Curve = Curve.new()
@export_range(0.0, 10.0, 0.001) var ball_speed_player_duration: float = 1.0
@onready var ball_speed_player_time := ball_speed_player_duration

@export_group("Ball collision")
@export_category("Wall")
@export_range(0.0, 90.0, 0.001, "degrees") var wall_angle_limit_min := 0.0
@export_range(0.0, 90.0, 0.001, "degrees") var wall_angle_limit_max := 90.0
@export_category("Brick")
@export_range(0.0, 90.0, 0.001, "degrees") var brick_angle_limit_min := 0.0
@export_range(0.0, 90.0, 0.001, "degrees") var brick_angle_limit_max := 90.0

@onready var player_velocity = Vector2.ZERO

var score := 0
var brick_progress := 0.0

@onready var ball_speed = base_ball_speed
@onready var ball_direction = initial_ball_direction

signal finished(score: int)

func _ready() -> void:
	pass

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _ball_speed_player_curve() -> float:
	return ball_speed_player_collision.sample(ball_speed_player_time / ball_speed_player_duration)

func _influence_curve() -> float:
	return influence_curve.sample(influence_time / influence_duration)

func _ball_speed() -> float:
	return base_ball_speed + _ball_speed_player_curve() + _influence_curve()

func _ball_velocity() -> Vector2:
	return ball_direction * _ball_speed()

func _limit_bounce_angle(normal: Vector2, direction: Vector2, limit_min: float, limit_max: float) -> Vector2:
	var angle = normal.angle_to(direction)
	var new_angle = signf(angle) * clampf(absf(angle), limit_min, limit_max)
	return Vector2.from_angle(normal.angle() + new_angle)

func _play_sound(sound: Resource) -> void:
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.stream = sound
	$AudioStreamPlayer2D.play()

func _calc_influence() -> void:
	var distance := absf(player.position.y - ball.position.y)
	var inside := distance >= influence_min_distance and distance <= influence_max_distance
	if influence_state == InfluenceState.TOO_FAR:
		if inside:
			influence_state = InfluenceState.AVAILABLE
	elif influence_state == InfluenceState.AVAILABLE:
		if not inside:
			influence_state = InfluenceState.TOO_FAR
		else:
			if Input.is_action_just_pressed("Boost"):
				influence_state = InfluenceState.USED
				var amount := (distance - influence_min_distance) / (influence_max_distance - influence_min_distance)
				$Debug.values.last_boost = "%.2f%%" % (100.0 - (amount * 100.0))
				influence_time = amount * influence_duration
	
	elif influence_state == InfluenceState.USED:
		if not inside:
			influence_state = InfluenceState.TOO_FAR

	$Debug.influence.player = player.position
	$Debug.influence.ball = ball.position
	$Debug.influence.min_distance = influence_min_distance
	$Debug.influence.max_distance = influence_max_distance

func _physics_process(delta: float) -> void:
	player.move_and_collide(player_velocity * delta)
	ball_speed_player_time = minf(ball_speed_player_duration, ball_speed_player_time + delta)
	influence_time = minf(influence_duration, influence_time + delta)

	# safe_margin = 1.0 here helps to unstuck the ball from rotating platforms
	# and player controlled platform
	var safe_margin := 1.0
	var collision = ball.move_and_collide(_ball_velocity() * delta, false, safe_margin)
	if collision:
		var normal: Vector2 = collision.get_normal()
		var bounce_angle_limit_min := 0.0
		var bounce_angle_limit_max := 90.0

		if collision.get_collider() == player:
			_play_sound(CollisionSound)

			ball.position.y = minf(player.position.y - 48.0, ball.position.y)

			# Disables corner or side reflections from pad by overriding the normal
			var offset := player.position.x - collision.get_position().x

			var offset_normalized := offset / player_collision_shape.size.x
			var angle = reflect_amount * -offset_normalized
			ball_speed_player_time = 0.0

			ball_direction = Vector2.UP.rotated(angle)

		elif collision.get_collider() is Brick:
			var brick := collision.get_collider() as Brick
			if brick.apply_damage(1):
				_play_sound(DestroySound)
				score += 1
				# var new_brick: Brick = BrickTscn.instantiate()
				# new_brick.position = brick.position
				# new_brick.position.y -= 150.0
				# add_child(new_brick)
			else:
				_play_sound(Collision2Sound)
			var amin := deg_to_rad(brick_angle_limit_min)
			var amax := deg_to_rad(brick_angle_limit_max)
			ball_direction = ball_direction.bounce(normal).normalized()
			ball_direction = _limit_bounce_angle(normal, ball_direction, amin, amax)
		else:
			_play_sound(CollisionSound)
			var amin := deg_to_rad(wall_angle_limit_min)
			var amax := deg_to_rad(wall_angle_limit_max)
			ball_direction = ball_direction.bounce(normal).normalized()
			ball_direction = _limit_bounce_angle(normal, ball_direction, amin, amax)

		if spawn_on_collision:
			var tmp: Node2D = spawn_on_collision.instantiate()
			tmp.position = collision.get_position() 
			add_child(tmp)

		bounce_angle_limit_min = deg_to_rad(bounce_angle_limit_min)
		bounce_angle_limit_max = deg_to_rad(bounce_angle_limit_max)


		# $Debug.bounce.velocity_in = _ball_velocity()

		# $Debug.bounce.velocity_out_unlimited = _ball_velocity()

		# $Debug.bounce.velocity_out = _ball_velocity()
		# $Debug.bounce.angle_min = bounce_angle_limit_min
		# $Debug.bounce.angle_max = bounce_angle_limit_max
		# $Debug.bounce.position = collision.get_position()
		# $Debug.bounce.normal = normal
		# $Debug.queue_redraw()

	_calc_influence()

	if ball.position.y > player.position.y:
		if finished.get_connections().is_empty():
			get_tree().reload_current_scene()
		else:
			finished.emit(score)

func _process(_delta: float) -> void:
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	player_velocity.x = direction * player_speed
	$Debug.update_value("score", score)
	$Debug.update_value("$Bricks.get_child_count()", $Bricks.get_child_count())
	$Debug.update_value("_ball_speed()", _ball_speed())
	$Debug.update_value("_ball_speed_player_curve()", _ball_speed_player_curve())
	$Debug.update_value("_influence_curve()", _influence_curve())
