extends Node2D

var ball_direction = Vector2(-1.0, 1.0).normalized()
var ball_speed = 500.0
@onready var p1: CharacterBody2D = $Paddle1
var ball: CharacterBody2D = null
var player_speed = 400.0
var walls = []
var halt = false

@onready var boi: AnimatedSprite2D = $Ball.find_child("Boi")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walls.push_back($WallLeft)
	walls.push_back($WallRight)
	walls.push_back($WallTop)
	ball = self.find_child("Ball")
	ball.velocity = ball_speed * ball_direction
	get_window().position -= get_window().position / 2
	get_window().size *= 2.0

func _input(event) -> void:
	pass

func _physics_process(delta: float) -> void:
	if halt:
		return
	var col1 = p1.move_and_collide(p1.velocity * delta)
	var col = ball.move_and_collide(ball.velocity * delta)
	if col != null:
		if -1 != walls.find(col.get_collider()):
			if col.get_normal() == Vector2.RIGHT:
				ball_direction.x = -ball_direction.x
				ball_direction = ball_direction.normalized()
			elif col.get_normal() == Vector2.LEFT:
				ball_direction.x = -ball_direction.x
				ball_direction = ball_direction.normalized()
			elif col.get_normal() == Vector2.DOWN:
				ball_direction.y = -ball_direction.y
				ball_direction = ball_direction.normalized()
		elif p1 == col.get_collider():
			var d = ball_direction
			var n = col.get_normal()
			var r = d - 2.0 * (d.dot(n)) * n
			ball_direction = r.normalized()
			print(ball_direction)
			var line = Line2D.new()
			line.add_point(col.get_position())
			line.add_point(col.get_position() + r.normalized() * 20.0)
			var node = Node2D.new()
			node.draw_rect(Rect2(0.0, 0.0, 500.0 ,500.0), Color.RED)
			print(col.get_normal())
			self.add_child(line)
			self.add_child(node)

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
