extends Node2D

# DONE. Restrict reflection normal from player pad to Vector2.UP
# DONE. 3 states for bricks.
# DONE. Spawn nodes on collision
# DONE. Bricks spawn on timer and scroll down. Generated grid, scrolls down.
# DONE. When ball is close to pad and F is pressed, extra boost is applied. 3 seperate influence zones.
# DONE. Make player reflection angle like in DX-BALL
# DONE. Mouse controls. Pad goes to mouse cursor with slight lag.
# DONE. Slow down scrolling.
# DONE. More gaps to extend the game.

### Buy power ups for score:
### When score threshold is reached, allow to select one out of three.
## Power up how many bricks a ball can go through.
## Power up splash damage.

## Power up buy multiple balls.
## Power up critical boost other power ups.
## Power up horizontal boost. Limit reflection angle.
# ????. When large chunk of bricks is detached from other bricks by collision, destroy the bricks.
# Multi-hit brick explodes with radius.
# Zone of influence:
## Destroy bricks.
## Slow down ball.
# Sound

const Brick = preload("res://brick.gd")
const Ball = preload("res://ball.gd")
const BrickTscn = preload("res://brick.tscn")
const RotatingBrick = preload("res://rotating_brick.gd")

@onready var player: AnimatableBody2D = $Player
@onready var player_collision_shape: RectangleShape2D = player.find_child("CollisionShape2D", false).shape
@onready var ball: Ball = $Ball
@onready var debug: Node2D = $Debug

@export_group("Common")

@export var influence_curve: Curve = Curve.new()
@export var ball_speed_player_collision: Curve = Curve.new()

@export var player_speed := 500.0
@export var reflect_amount := 1.0
@export var spawn_on_collision: PackedScene = null

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

signal finished(score: int)

func _ready() -> void:
	pass

func _limit_bounce_angle(normal: Vector2, direction: Vector2, limit_min: float, limit_max: float) -> Vector2:
	var angle = normal.angle_to(direction)
	var new_angle = signf(angle) * clampf(absf(angle), limit_min, limit_max)
	return Vector2.from_angle(normal.angle() + new_angle)

func _play_sound(sound: AudioStreamPlayer) -> void:
	sound.play()

func _update_score_graphics() -> void:
	$Score.text = "Score: " + str(score)

func _physics_process(delta: float) -> void:
	player.move_and_collide(Vector2(player.get_local_mouse_position().x * 0.5, 0.0))

	# safe_margin = 1.0 here helps to unstuck the ball from rotating platforms
	# and player controlled platform
	var safe_margin := 1.0
	var velocity = ball.velocity(influence_curve, ball_speed_player_collision)
	var collision = ball.move_and_collide(velocity * delta, false, safe_margin)
	if collision:
		var normal: Vector2 = collision.get_normal()

		if collision.get_collider() == player:
			_play_sound($Sounds/Collision)

			ball.position.y = minf(player.position.y - 48.0, ball.position.y)

			var offset := player.position.x - collision.get_position().x
			var offset_normalized := offset / player_collision_shape.size.x
			var angle = reflect_amount * -offset_normalized
			ball.player_time = 0.0

			ball.direction = Vector2.UP.rotated(angle)

		elif collision.get_collider() is Brick:
			var brick := collision.get_collider() as Brick

			if brick.apply_damage(1):
				_play_sound($Sounds/Destroy)
				score += 1
				_update_score_graphics()
				if spawn_on_collision:
					var tmp: Node2D = spawn_on_collision.instantiate()
					tmp.position = collision.get_position() 
					add_child(tmp)
			else:
				_play_sound($Sounds/Collision2)

			var amin := deg_to_rad(brick_angle_limit_min)
			var amax := deg_to_rad(brick_angle_limit_max)
			ball.direction = ball.direction.bounce(normal).normalized()
			ball.direction = _limit_bounce_angle(normal, ball.direction, amin, amax)
		else:
			_play_sound($Sounds/Collision)
			var amin := deg_to_rad(wall_angle_limit_min)
			var amax := deg_to_rad(wall_angle_limit_max)
			ball.direction = ball.direction.bounce(normal).normalized()
			ball.direction = _limit_bounce_angle(normal, ball.direction, amin, amax)

	if ball.calc_influence(player.position, Input.is_action_just_pressed("Boost")):
		_play_sound($Sounds/Boost)

	if ball.position.y > player.position.y:
		if finished.get_connections().is_empty():
			get_tree().reload_current_scene()
		else:
			finished.emit(score)

func _process(_delta: float) -> void:
	if OS.has_feature('debug'):
		$Debug.update_value("score", score)
		$Debug.update_value("$Bricks.get_child_count()", $Bricks.get_child_count())
		$Debug.update_value("player_velocity", player_velocity)
