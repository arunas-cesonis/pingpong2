extends Node2D

## 1. Add objects that have health points and can be killed
## 2. Ball collision vs rotating shapes

const Brick = preload("res://brick.gd")

@onready var player: AnimatableBody2D = $Player
@onready var ball: AnimatableBody2D = $Ball
@onready var debug: Node2D = $Debug

@export var ball_direction := Vector2(0.0, 1.0)
@export var ball_speed := 500.0
@export var player_speed := 500.0
@export var reflect_amount := 0.5

@onready var player_velocity = Vector2.ZERO
@onready var ball_velocity = ball_direction * ball_speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	player.move_and_collide(player_velocity * delta)
	var collision = ball.move_and_collide(ball_velocity * delta)
	if collision:
		var normal: Vector2 = collision.get_normal()
		if collision.get_collider() == player:
			var offset = player.position.x - collision.get_position().x
			var shape: RectangleShape2D = player.get_child(0).shape
			var offset_normalized = offset / shape.size.x
			var angle_adjustment = offset_normalized * reflect_amount
			var normal_offseted = Vector2.from_angle(normal.angle() - angle_adjustment)
			normal = normal_offseted
		elif collision.get_collider() is Brick:
			var brick := collision.get_collider() as Brick
			brick.apply_damage(51.0)
			
		$Debug.bounce.velocity_in = ball_velocity
		ball_velocity = ball_velocity.bounce(normal)
		$Debug.bounce.velocity_out = ball_velocity
		$Debug.bounce.position = collision.get_position()
		$Debug.bounce.normal = normal
		$Debug.queue_redraw()
	if ball.position.y > player.position.y:
		get_tree().reload_current_scene()
		
func _process(_delta: float) -> void:
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	player_velocity.x = direction * player_speed
