extends Area2D

@export var chakram_speed = 500
var chakram_direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += chakram_speed * chakram_direction * delta


func setup(initial_pos: Vector2, direction: Vector2):
	position = initial_pos
	chakram_direction = direction


func _on_body_entered(body: Node2D) -> void:
	queue_free()
