extends Node

func add_effect(particle_effect: Node, _position: Vector2) -> void:
	add_child(particle_effect)
	particle_effect.activate(_position)
	