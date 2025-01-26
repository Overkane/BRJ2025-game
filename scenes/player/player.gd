extends CharacterBody2D

# Trajectory drawing
# @onready var trajectory: Line2D = $Trajectory
const MAX_TRAJECTORY_POINTS = 100

# Player related
const MAX_SPACE_JUMP_SPEED = 200
var canUseSpaceJump := false
var currentMousePos := Vector2.ZERO

# Magnetron related
const MAGNETRON_ORBITING_ANGULAR_SPEED := 1.75
const MAGNETRON_SUCKING_SPEED := 200.
var currentMagnetron: CharacterBody2D
var magnetron_orbitting_radius := 0.0
var magnetron_orbitting_direction := 1
var magnetron_initial_orbitting_angle := 0.0

# Checkpoint system
var magnetronCheckpoint: CharacterBody2D
var checkpointPosition: Vector2
var checkpointAnglePosition: float
var checkpointOrbittingRadius: float
var checkpoint_magnetron_orbitting_direction: float


func _ready():
	$GPUParticles2D.emitting = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and canUseSpaceJump:
		currentMousePos = get_global_mouse_position()
	if event.is_action_released("LMB") and canUseSpaceJump:
		$AnimatedSprite2D.play("space_jump")

		# Can jump only when orbiting
		if currentMagnetron != null:
			$GPUParticles2D.emitting = true
			canUseSpaceJump = false
			currentMagnetron = null
		
		# Calculate jump power based on mouse distance, but can't exceed MAX_SPACE_JUMP_SPEED
		var lastMousePos = get_global_mouse_position()
		var velocity_vector = (currentMousePos - lastMousePos)
		var finite_vector = velocity_vector.normalized() * min(velocity_vector.length(), MAX_SPACE_JUMP_SPEED)
		velocity = finite_vector
	if event.is_action_released("RMB") and $Node/PullTrajectory.visible:
		$Node/PullTrajectory.clear_points()
		$Node/PullTrajectory.hide()

func _physics_process(_delta: float) -> void:
	var oldPosition = global_position

	# If player connected to magnetron, then he spins around it
	if currentMagnetron != null:
		velocity = Vector2.ZERO
		magnetron_initial_orbitting_angle = magnetron_initial_orbitting_angle + magnetron_orbitting_direction * MAGNETRON_ORBITING_ANGULAR_SPEED * _delta
		global_position = (Vector2(1,0) * magnetron_orbitting_radius).rotated(magnetron_initial_orbitting_angle) + currentMagnetron.global_position

	# Sucking towards closests visible magnetron in not orbitting near magnetron
	if Input.is_action_pressed("RMB") and not canUseSpaceJump:
		var area2DNearby = $MagnetronPullChecker.get_overlapping_bodies() as Array[CharacterBody2D]
		var distancesToMagnetrons := {}
		var closestDistance := 100000.0 # TODO fix condition

		if area2DNearby.size() > 0:
			for staticBody in area2DNearby:
				if staticBody.is_in_group("magnetrons"):
					var space_state = get_world_2d().direct_space_state

					var query = PhysicsRayQueryParameters2D.create(global_position, staticBody.global_position, 1)
					var result = space_state.intersect_ray(query)
					if result:
						if result.collider.is_in_group("magnetrons"):
							var distance = staticBody.global_position.distance_to(global_position)
							closestDistance = min(closestDistance, distance)

							distancesToMagnetrons[distance] = staticBody
		if closestDistance > 0 and closestDistance != 100000.0:
			# Apply force to the player, to move towards the closest magnetron
			var closestMagnetron = distancesToMagnetrons.get(closestDistance)
			var directionToMagnetron = global_position.direction_to(closestMagnetron.global_position)
			velocity = directionToMagnetron * MAGNETRON_SUCKING_SPEED
			if not $Node/PullTrajectory.visible:
				$Node/PullTrajectory.show()
			$Node/PullTrajectory.clear_points()
			$Node/PullTrajectory.add_point(global_position)
			$Node/PullTrajectory.add_point(closestMagnetron.global_position)

	# General movement
	var collision := move_and_collide(velocity * _delta)
	if collision:
		var isPathable = false # If player can pass through object without bouncing
		# var collider = collision.get_collider()
		# if collider is TileMapLayer:
		# 	var cellPosition: Vector2i = collider.local_to_map(collision.get_position())
		# 	var tileData: TileData = collider.get_cell_tile_data(cellPosition)
		# 	if tileData:
		# 		if tileData.get_custom_data("isTrap"):
		# 			on_death_reset()
		# 		elif tileData.get_custom_data("isActivator"):
		# 			destroyActivator(collider, cellPosition)
		# 			move_and_collide(velocity * _delta)
		# 			isPathable = true
		if not isPathable:
			velocity = velocity.bounce(collision.get_normal()) * 0.9
	
	rotation = global_position.direction_to(oldPosition).angle()


# When player enter magnetron zone, he can use space jump and orbits around the magnetron
func _on_player_entered_magnetron_zone(magnetron: CharacterBody2D, isCheckpoint: bool) -> void:
	$AnimatedSprite2D.play("idle")

	# No drawing of pull trajectory if came on orbit
	$Node/PullTrajectory.clear_points()
	$Node/PullTrajectory.hide()

	canUseSpaceJump = true
	$GPUParticles2D.emitting = false
	currentMagnetron = magnetron
	magnetron_orbitting_radius = global_position.distance_to(magnetron.global_position)
	magnetron_initial_orbitting_angle = magnetron.global_position.direction_to(global_position).angle()
	
	# Determine the direction of orbitting
	var entryPoint = global_position - magnetron.global_position
	var cross = entryPoint.cross(velocity)
	magnetron_orbitting_direction = sign(cross) if cross != 0 else 1

	# Need to be last, so we save calculated values to checkpoint
	if isCheckpoint:
		activateCheckpoint(magnetron)


func activateCheckpoint(magnetron: CharacterBody2D) -> void:
	if magnetronCheckpoint != null:
		magnetronCheckpoint.deactivate_checkpoint()
	magnetron.activate_checkpoint()

	magnetronCheckpoint = currentMagnetron
	checkpointPosition = global_position
	checkpointAnglePosition = magnetron_initial_orbitting_angle
	checkpointOrbittingRadius = magnetron_orbitting_radius
	checkpoint_magnetron_orbitting_direction = magnetron_orbitting_direction

func on_death_reset() -> void:
	if magnetronCheckpoint != null:
		currentMagnetron = magnetronCheckpoint
		global_position = checkpointPosition
		magnetron_initial_orbitting_angle = checkpointAnglePosition
		magnetron_orbitting_radius = checkpointOrbittingRadius
		canUseSpaceJump = true
		velocity = Vector2.ZERO
	else:
		print("No checkpoint found")

# # Draw trajectory till first collision or MAX_TRAJECTORY_POINTS
# func updateTrajectory(delta) -> void:
# 	trajectory.clear_points()
# 	var pos := Vector2.ZERO

# 	# Same calculation like when mouse input is released
# 	var lastMousePos = get_global_mouse_position()
# 	var velocity_vector = (currentMousePos - lastMousePos)
# 	var finite_vector = velocity_vector.normalized() * min(velocity_vector.length(), MAX_SPACE_JUMP_SPEED)
# 	var trajectory_velocity = finite_vector

# 	for i in range(MAX_TRAJECTORY_POINTS):
# 		trajectory.add_point(pos)
# 		pos += trajectory_velocity * delta

# 		var collision = $Trajectory/TrajectoryCollisionChecker.move_and_collide(trajectory_velocity * delta)
# 		if collision:
# 			break
