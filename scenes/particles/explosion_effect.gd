extends CPUParticles2D

func activate(_pos: Vector2) -> void:
	global_position = _pos
	emitting = true
	$AudioStreamPlayer2D.play()
