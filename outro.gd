extends Node2D

signal play_again_pressed()

func set_score(score: int) -> void:
	$Score.text = "SCORE:" + str(score)

func _on_play_again_pressed() -> void:
	play_again_pressed.emit()
