extends RayCast2D

var canHit := false

signal player_hit
signal laser_beam_end

func _ready():
	$AnimationPlayer.animation_finished.connect(on_laser_born)

func _physics_process(_delta):
	var cast_point = target_position
	force_raycast_update()

	if is_colliding():
		cast_point = to_local(get_collision_point())

	$Line2D.points[1] = cast_point
	if get_collider() != null and get_collider().is_in_group("player") and canHit:
		player_hit.emit()

func _enter_tree() -> void:
	canHit = false


func setup(_position: Vector2, angle: float):
	global_position = _position
	target_position = Vector2.RIGHT.rotated(angle) * 800
	$Line2D.points[0] = Vector2.ZERO
	$Line2D.points[1] = target_position


func on_laser_born(_animation_name: String) -> void:
	canHit = true
	await get_tree().create_timer(2).timeout
	laser_beam_end.emit()
	queue_free()