extends Area2D
var explosion_effect_scene := preload("res://scenes/particles/explosion_effect.tscn")


func destroy() -> void:
	var explosion_effect = explosion_effect_scene.instantiate()
	ParticleSystem.add_effect(explosion_effect, global_position)
	queue_free()
