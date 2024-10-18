extends Node2D

@onready var player: AnimatableBody2D = $Player
@onready var ball: AnimatableBody2D = $Ball
@onready var debug: Node2D = $Debug
var ball_velocity = Vector2.from_angle(PI / 1.5) * 500.0
var player_velocity = Vector2.ZERO
const player_speed = 500.0
var halt = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#get_window().position -= get_window().position / 2
	#get_window().size *= 2.0

func _input(event) -> void:
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
			var normal_offseted = Vector2.from_angle(normal.angle() - offset_normalized * 0.5)
			normal = normal_offseted
			
		$Debug.bounce.velocity_in = ball_velocity
		ball_velocity = ball_velocity.bounce(normal)
		$Debug.bounce.velocity_out = ball_velocity
		$Debug.bounce.position = collision.get_position()
		$Debug.bounce.normal = normal
		$Debug.queue_redraw()
		
func _process(delta: float) -> void:
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	player_velocity.x = direction * player_speed
