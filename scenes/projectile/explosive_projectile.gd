extends Area2D
# Projectile can kill player on impact or it self-explode in some area after max distance were travelled

signal player_hit

const AOE_RADIUS := 70.
const MAX_ANIM_FPS = 10
const SPEED = 50
var initial_pos: Vector2
var target_pos: Vector2

var explosion_effect_scene := preload("res://scenes/particles/explosion_effect.tscn")

func _ready():
	body_entered.connect(_on_body_enter)
	

func _draw():
	draw_circle(Vector2.ZERO, AOE_RADIUS, Color(1, 0, 0, 0.5)) 

func _physics_process(delta):
	global_position = global_position.move_toward(target_pos, SPEED * delta)

	var initDistance = initial_pos.distance_to(target_pos) 
	var curDistance = global_position.distance_to(target_pos) 

	var distance_factor = 1.0 - curDistance / initDistance
	$AnimatedSprite2D.speed_scale = 1. + distance_factor * MAX_ANIM_FPS

	if global_position == target_pos:
		await get_tree().create_timer(1.5).timeout
		boom()


func boom():
	var explosion_effect = explosion_effect_scene.instantiate()
	explosion_effect.scale = Vector2(2, 2)
	ParticleSystem.add_effect(explosion_effect, global_position)
	for body in $ExplosionRadius2D.get_overlapping_bodies():
		if body.is_in_group("player"):
			player_hit.emit()
	queue_free()

func setup(_position: Vector2, _target_pos: Vector2):
	global_position = _position
	rotation = target_pos.angle()
	target_pos = _target_pos
	initial_pos = _position


func _on_body_enter(_body: Node2D):
	boom()