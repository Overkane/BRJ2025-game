extends CharacterBody2D

# Player related
const MAX_SPACE_JUMP_SPEED = 200
var canUseSpaceJump := true
var currentMousePos := Vector2.ZERO

# Magnetron related
const MAGNETRON_ORBITING_ANGULAR_SPEED := 1.5
var currentMagnetron: CharacterBody2D
var magnetron_orbitting_radius := 0.0
var magnetron_orbitting_direction := 1
var magnetron_initial_orbitting_angle := 0.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and canUseSpaceJump:
		currentMousePos = get_global_mouse_position()
	if event.is_action_released("LMB") and canUseSpaceJump:
		# Can jump only when orbiting
		if currentMagnetron != null:
			canUseSpaceJump = false
			currentMagnetron = null
		
		# Calculate jump power based on mouse distance, but can't exceed MAX_SPACE_JUMP_SPEED
		var lastMousePos = get_global_mouse_position()
		var velocity_vector = (currentMousePos - lastMousePos)
		var finite_vector = velocity_vector.normalized() * min(velocity_vector.length(), MAX_SPACE_JUMP_SPEED)
		velocity = finite_vector

func _physics_process(_delta: float) -> void:
	# If player connected to magnetron, then he spins around it
	if currentMagnetron != null:
		velocity = Vector2.ZERO
		magnetron_initial_orbitting_angle = magnetron_initial_orbitting_angle + magnetron_orbitting_direction * MAGNETRON_ORBITING_ANGULAR_SPEED * _delta
		global_position = (Vector2(1,0) * magnetron_orbitting_radius).rotated(magnetron_initial_orbitting_angle) + currentMagnetron.global_position

	# Sucking towards closests visible magnetron in not orbitting near magnetron
	if not canUseSpaceJump:
		var area2DNearby = $Area2D.get_overlapping_bodies() as Array[CharacterBody2D]
		var distancesToMagnetrons := {}
		var closestDistance := 100000.0 # TODO fix condition

		if area2DNearby.size() > 0:
			for staticBody in area2DNearby:
				if staticBody.is_in_group("magnetrons"):
					var space_state = get_world_2d().direct_space_state

					var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), staticBody.global_position, 1)
					var result = space_state.intersect_ray(query)
					if result:
						var distance = staticBody.global_position.distance_to(global_position)
						closestDistance = min(closestDistance, distance)

						distancesToMagnetrons[distance] = staticBody
		if closestDistance > 0 and closestDistance != 100000.0:
			# Apply force to the player, to move towards the closest magnetron
			var closestMagnetron = distancesToMagnetrons.get(closestDistance)
			var directionToMagnetron = global_position.direction_to(closestMagnetron.global_position)
			velocity += directionToMagnetron

	# General movement
	var collision := move_and_collide(velocity * _delta)
	if collision:
		var collider = collision.get_collider()
		print(collider)
		print(global_position)
		if collider is TileMapLayer:
			var tileData = collider.get_cell_tile_data(collider.local_to_map(collision.get_position()))
			print(tileData)
			if tileData:
				print(tileData.get_custom_data("isActivator"))
				print(tileData.get_custom_data("isTrap"))
		velocity = velocity.bounce(collision.get_normal())


# When player enter magnetron zone, he can use space jump and orbits around the magnetron
func _on_player_entered_magnetron_zone(magnetron: CharacterBody2D) -> void:

	canUseSpaceJump = true
	currentMagnetron = magnetron
	magnetron_orbitting_radius = global_position.distance_to(magnetron.global_position)
	magnetron_initial_orbitting_angle = magnetron.global_position.direction_to(global_position).angle()
	
	# Determine the direction of orbitting
	var entryPoint = global_position - magnetron.global_position
	var cross = entryPoint.cross(velocity)
	magnetron_orbitting_direction = sign(cross) if cross != 0 else 1
