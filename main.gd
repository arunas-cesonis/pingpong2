extends Node2D

const Game = preload("res://game.tscn")
const Intro = preload("res://intro.tscn")
const Outro = preload("res://outro.tscn")

var current_scene: Node = null

func _input(_event) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not get_tree().paused

func _set_current_scene(s: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = s
	add_child(s)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var intro = Intro.instantiate()
	intro.connect("play_pressed", _on_play_pressed)
	_set_current_scene(intro)

func _on_game_finished(score: int) -> void:
	var outro = Outro.instantiate()
	outro.set_score(score)
	outro.connect("play_again_pressed", _on_play_again_pressed)
	_set_current_scene(outro)

func _on_play_pressed() -> void:
	var game = Game.instantiate()
	game.connect("finished", _on_game_finished)
	_set_current_scene(game)

func _on_play_again_pressed() -> void:
	var game = Game.instantiate()
	game.connect("finished", _on_game_finished)
	_set_current_scene(game)
