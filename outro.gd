extends Node2D

func set_score(score: int) -> void:
	$Score.text = "SCORE:" + str(score)