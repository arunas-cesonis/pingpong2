extends Node2D

var ball_direction = Vector2(-1.0, 1.0).normalized()
var ball_speed = 500.0
var p1: CharacterBody2D = null
var ball: CharacterBody2D = null
var player_speed = 800.0
var walls = []

@onready var boi: AnimatedSprite2D = $Ball.find_child("Boi")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walls.push_back(self.find_child("WallLeft"))
	walls.push_back(self.find_child("WallRight"))
	p1 = self.find_child("Paddle1")
	ball = self.find_child("Ball")
	ball.velocity = ball_speed * ball_direction

func _input(event) -> void:
	pass

func _physics_process(delta: float) -> void:
	p1.move_and_collide(p1.velocity * delta)
	var col = ball.move_and_collide(ball.velocity * delta)
	print(Vector2.RIGHT)
	if col != null:
		if -1 != walls.find(col.get_collider()):
			if col.get_normal() == Vector2.RIGHT:
				ball_direction.x = -ball_direction.x
				ball_direction = ball_direction.normalized()
	ball.velocity = ball_direction * ball_speed			
	
			# print(ball_direction.angle(), col.get_normal())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("MoveLeft"):
		p1.velocity = Vector2(-player_speed, 0.0)
	elif Input.is_action_pressed("MoveRight"):
		p1.velocity = Vector2(player_speed, 0.0)
	else:
		p1.velocity = Vector2.ZERO
	#var ball = self.find_child("Ball")
	#var direction = 0.0
	#if Input.is_action_pressed("MoveLeft"):
		#direction = -1.0
	#elif Input.is_action_pressed("MoveRight"):
		#direction = 1.0
	#if direction != 0.0:
		#var p = self.find_child("Paddle1")
		#p.position.x += direction * delta * 600.0
	pass
