extends Node2D

@onready var play_button := $PlayButton

signal play_pressed()

func _on_play_button_pressed() -> void:
	play_pressed.emit()
