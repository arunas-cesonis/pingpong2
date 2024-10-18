extends Node2D

@onready var player: AnimatableBody2D = $Player
@onready var ball: AnimatableBody2D = $Ball
var ball_velocity = Vector2.from_angle(PI / 1.5) * 500.0
var player_velocity = Vector2.ZERO
const player_speed = 500.0
var walls = []
var halt = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walls.push_back($WallLeft)
	walls.push_back($WallRight)
	get_window().position -= get_window().position / 2
	get_window().size *= 2.0

func _input(event) -> void:
	pass

func _physics_process(delta: float) -> void:
	player.move_and_collide(player_velocity * delta)
	var collision = ball.move_and_collide(ball_velocity * delta)
	if collision:
		ball_velocity = ball_velocity.bounce(collision.get_normal())
		
func _process(delta: float) -> void:
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	player_velocity.x = direction * player_speed
