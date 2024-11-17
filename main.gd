extends Node2D

const Game = preload("res://game.tscn")
const Intro = preload("res://intro.tscn")
const Outro = preload("res://outro.tscn")

var current_scene: Node = null
var in_game := false
var config := ConfigFile.new()
@onready var music: AudioStreamPlayer = $Music

func _config_get_bool(key: String) -> bool:
	config.load("user://config.cfg")
	return config.get_value("config", key, false)

func _config_set_bool(key: String, enabled: bool) -> void:
	config.set_value("config", key, enabled)
	config.save("user://config.cfg")

func _set_cursor(yes: bool) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if yes else Input.MOUSE_MODE_HIDDEN)

func _init() -> void:
	_set_cursor(_config_get_bool("cursor"))

func _input(_event) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("Toggle Music"):
		var enabled := not _config_get_bool("music")
		music.playing = enabled
		_config_set_bool("music", enabled)
	if Input.is_action_just_pressed("Toggle Cursor"):
		var enabled := not _config_get_bool("cursor")
		_set_cursor(enabled)
		_config_set_bool("cursor", enabled)
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
	music.playing = _config_get_bool("music")
	_set_cursor(_config_get_bool("cursor"))
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