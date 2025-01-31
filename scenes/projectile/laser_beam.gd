extends RayCast2D

signal player_hit
signal laser_beam_end

func _physics_process(_delta):
	var cast_point = target_position
	force_raycast_update()

	if is_colliding():
		cast_point = to_local(get_collision_point())
	
	$Line2D.points[1] = cast_point
	
	if get_collider().is_in_group("player"):
		player_hit.emit()

func _enter_tree() -> void:
	appear()
	await get_tree().create_timer(3).timeout
	disappear()
	laser_beam_end.emit()
	queue_free()


func setup(_position: Vector2, angle: float):
	global_position = _position
	target_position = Vector2.RIGHT.rotated(angle) * 800
	$Line2D.points[0] = Vector2.ZERO
	$Line2D.points[1] = target_position

func appear() -> void:
	var tween = create_tween()
	tween.tween_property($Line2D, "width", 10.0, 0.2)

func disappear() -> void:
	var tween = create_tween()
	tween.tween_property($Line2D, "width", 0, 0.1)
