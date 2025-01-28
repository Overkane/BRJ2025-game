extends Area2D

const SPEED = 125
var direction := Vector2.ZERO


func setup(_position: Vector2, _direction: Vector2):
	global_position = _position
	direction = _direction
	rotation = direction.angle()

func _process(delta):
	global_position += direction * SPEED * delta
