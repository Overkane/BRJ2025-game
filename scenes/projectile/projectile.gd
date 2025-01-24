extends Area2D

const SPEED = 125
var direction := Vector2.ZERO


func setup(_position: Vector2, _direction: Vector2):
	global_position = _position
	direction = _direction

func _process(delta):
	global_position += direction * SPEED * delta
