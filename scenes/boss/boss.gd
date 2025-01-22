extends CharacterBody2D

signal hit

@export var MAX_LIFE = 100.
@export var SPEED = 200.

var current_speed = SPEED
var life = MAX_LIFE
var player_target


func _physics_process(delta: float) -> void:
	if player_target != null:
		position += SPEED * position.direction_to(player_target.position) * delta


func setup(player: CharacterBody2D):
	player_target = player

func get_hit(damageDealt: int):
	life -= damageDealt
	if life <= 0:
		queue_free()
		hit.emit(0)
	else:
		hit.emit(life / MAX_LIFE * 100)
