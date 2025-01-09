extends Area2D

@export var SPEED = 500.
@export var DAMAGE = 20.

var direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += SPEED * direction * delta


func setup(initial_pos: Vector2, throw_direction: Vector2):
	position = initial_pos
	direction = throw_direction


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.get_hit(DAMAGE)
	queue_free()
