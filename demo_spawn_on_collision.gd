extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	$CPUParticles2D.restart()

func _on_cpu_particles_2d_finished() -> void:
	self.queue_free()
