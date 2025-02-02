extends Node

var player_camera: Camera2D
var world_node
var rng = RandomNumberGenerator.new()

# Camera shake
var randomStrenght := 25.0
var shake_strength := 0.0
var shake_fade := 5.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		player_camera.offset = randomOffset()


func shake_camera() -> void:
	shake_strength = randomStrenght

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))