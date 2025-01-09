extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

const SPEED = 400.0

func _physics_process(_delta: float) -> void:
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x > 0:
		_animated_sprite.flip_h = false
	elif direction.x < 0:
		_animated_sprite.flip_h = true
	if direction == Vector2.ZERO:
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("walk")
	
	velocity = direction * SPEED
	move_and_slide()
