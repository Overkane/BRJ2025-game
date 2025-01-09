extends CharacterBody2D

signal hit

@export var SPEED = 300.
@export var MAX_LIFE = 100.
@export var life = MAX_LIFE

func get_hit(damageDealt: int):
	life -= damageDealt
	if life <= 0:
		queue_free()
		hit.emit(0)
	else:
		hit.emit(life / MAX_LIFE * 100)
