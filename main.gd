extends Node2D

const Game = preload("res://game.tscn")
const Intro = preload("res://intro.tscn")
const Outro = preload("res://outro.tscn")

var current_scene: Node = null
var in_game := false

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	if in_game:
		if Input.is_action_just_pressed("Pause"):
			get_tree().paused = not get_tree().paused
	else:
		if Input.is_action_just_pressed("Start"):
			_on_play_pressed()

func _set_current_scene(s: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = s
	add_child(s)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	in_game = false
	var intro = Intro.instantiate()
	_set_current_scene(intro)

func _on_game_finished(score: int) -> void:
	in_game = false
	var outro = Outro.instantiate()
	outro.set_score(score)
	_set_current_scene(outro)

func _on_play_pressed() -> void:
	in_game = true
	var game = Game.instantiate()
	game.connect("finished", _on_game_finished)
	_set_current_scene(game)