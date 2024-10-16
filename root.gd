extends Node2D


var ball_velocity = Vector2(0.0, 500.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _input(event) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ball = self.find_child("Ball")
	var direction = 0.0
	if Input.is_action_pressed("MoveLeft"):
		direction = -1.0
	elif Input.is_action_pressed("MoveRight"):
		direction = 1.0
	if direction != 0.0:
		var p: Node2D = self.find_child("Paddle1")
		p.position.x += direction * delta * 600.0
		
	ball.position += ball_velocity * delta
	pass
