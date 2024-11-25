extends AnimatableBody2D

var base_speed := 500.0
var direction := Vector2.DOWN
var player_duration := 1.0
var influence_duration := 1.0
var player_time := player_duration
var influence_time := influence_duration
var influence_min_distance := 20.0
var influence_max_distance := 200.0

enum InfluenceState {TOO_FAR, USED, AVAILABLE}
var influence_state: InfluenceState = InfluenceState.TOO_FAR

func _physics_process(delta: float) -> void:
	player_time = minf(player_duration, player_time + delta)
	influence_time = minf(influence_duration, influence_time + delta)

func velocity(influence_curve: Curve, player_curve: Curve) -> Vector2:
	var player_speed = player_curve.sample(player_time / player_duration)
	var influence_speed = influence_curve.sample(influence_time / influence_duration)
	return direction * (base_speed + player_speed + influence_speed)

func calc_influence(player_position: Vector2, boost_pressed: bool) -> bool:
	var distance := absf(player_position.y - position.y)
	var inside := distance >= influence_min_distance and distance <= influence_max_distance
	if influence_state == InfluenceState.TOO_FAR:
		if inside:
			influence_state = InfluenceState.AVAILABLE
	elif influence_state == InfluenceState.AVAILABLE:
		if not inside:
			influence_state = InfluenceState.TOO_FAR
		else:
			if boost_pressed:
				influence_state = InfluenceState.USED
				var amount := (distance - influence_min_distance) / (influence_max_distance - influence_min_distance)
				influence_time = amount * influence_duration
				return true
	
	elif influence_state == InfluenceState.USED:
		if not inside:
			influence_state = InfluenceState.TOO_FAR

	return false