extends Node2D

const Game = preload("res://game.tscn")
const Intro = preload("res://intro.tscn")

@onready var intro := Intro.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro.connect("play_pressed", _on_play_pressed)
	add_child(intro)

func _on_play_pressed() -> void:
	intro.queue_free()
	add_child(Game.instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
