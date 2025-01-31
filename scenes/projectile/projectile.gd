extends Area2D

signal player_hit

const SPEED = 125
var direction := Vector2.ZERO


func _ready():
	body_entered.connect(_on_body_enter)

func _process(delta):
	global_position += direction * SPEED * delta


func setup(_position: Vector2, _direction: Vector2):
	global_position = _position
	direction = _direction
	rotation = direction.angle()


func _on_body_enter(body: Node2D):
	if body.is_in_group("player"):
		player_hit.emit()
	queue_free()
	