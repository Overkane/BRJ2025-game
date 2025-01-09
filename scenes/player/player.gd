extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _chakram_throw_point = $ChakramThrowPoint

@export var chakram_scene: PackedScene
@export var life = 3
@export var SPEED = 400.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_chakram"):
		throw_chakram()

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


func get_hit():
	life -= 1
	if life == 0:
		queue_free()

func throw_chakram():
	var chakram = chakram_scene.instantiate()
	var chakram_position = _chakram_throw_point.global_position
	var chakram_direction = chakram_position.direction_to(get_global_mouse_position())
	chakram.setup(chakram_position, chakram_direction)
	add_sibling(chakram)
