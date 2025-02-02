extends CharacterBody2D

signal player_moved

var explosion_effect_scene := preload("res://scenes/particles/explosion_effect.tscn")

# Player stats
var deathCount := 0
var timeElapsed := 0.

# Player related
const MAX_SPACE_JUMP_SPEED = 210.
const MIN_SPACE_JUMP_SPEED = 100.
var canUseSpaceJump := false
var canUseSpaceJumpBonus := false
var currentMousePos := Vector2.ZERO
var gradient: Gradient

# Magnetron related
const MAGNETRON_ORBITING_ANGULAR_SPEED := 1.75
const MAGNETRON_SUCKING_SPEED := 200.
var currentMagnetron: CharacterBody2D
var magnetron_orbitting_radius := 0.0
var magnetron_orbitting_direction := 1
var magnetron_initial_orbitting_angle := 0.0
var isMagnettronPulling := false

# Checkpoint system
var magnetronCheckpoint: CharacterBody2D
var checkpointPosition: Vector2
var checkpointAnglePosition: float
var checkpointOrbittingRadius: float
var checkpoint_magnetron_orbitting_direction: float
var isFirstCheckpoint := true # Don't play checkpoint sound on first checkpoint


func _ready():
	Globals.player_camera = $Camera2D

	# Color depends on velocity
	gradient = Gradient.new()
	gradient.add_point(MIN_SPACE_JUMP_SPEED, Color.GREEN)
	gradient.add_point((MIN_SPACE_JUMP_SPEED + MAX_SPACE_JUMP_SPEED) / 2, Color.YELLOW)
	gradient.add_point(MAX_SPACE_JUMP_SPEED, Color.RED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and hasSpaceJump():
		currentMousePos = get_global_mouse_position()

		%DirectionMarker.show()
	if event.is_action_released("LMB") and hasSpaceJump():
		$AnimatedSprite2D.play("space_jump")

		# Check _on_player_bonus_jump_pickup. Remove slow after jump, so you are not slowed during it.
		Engine.time_scale = 1.

		# Can jump only when orbiting
		if currentMagnetron != null:
			currentMagnetron = null
		
		resetSpaceJump()
		
		# Calculate jump power based on mouse distance, but can't exceed MAX_SPACE_JUMP_SPEED
		var lastMousePos = get_global_mouse_position()
		var velocity_vector = (global_position - lastMousePos) * 2
		var finite_vector = velocity_vector.normalized() * clamp(velocity_vector.length(), MIN_SPACE_JUMP_SPEED, MAX_SPACE_JUMP_SPEED)
		velocity = finite_vector

		%DirectionMarker.hide()
	if event.is_action_released("RMB"):
		%DirectionMarker.hide()
		if $Node/PullTrajectory.visible:
			isMagnettronPulling = false
			$Node/PullTrajectory.clear_points()
			$Node/PullTrajectory.hide()

func _process(_delta):
	if not get_tree().paused:
		timeElapsed += _delta

	if %DirectionMarker.visible:
		updateTrajectory()

func _physics_process(_delta: float) -> void:
	var oldPosition = global_position

	# If player connected to magnetron, then he spins around it
	if currentMagnetron != null:
		velocity = Vector2.ZERO
		magnetron_initial_orbitting_angle = magnetron_initial_orbitting_angle + magnetron_orbitting_direction * MAGNETRON_ORBITING_ANGULAR_SPEED * _delta
		global_position = (Vector2(1,0) * magnetron_orbitting_radius).rotated(magnetron_initial_orbitting_angle) + currentMagnetron.global_position

	# Check if can still pull, that means magnetron is still visible
	# if isMagnettronPulling:
	# 	var area2DNearby = $MagnetronPullChecker.get_overlapping_bodies() as Array[CharacterBody2D]
	# 	var distancesToMagnetrons := {}
	# 	var closestDistance := 100000.0 # TODO fix condition

	# 	if area2DNearby.size() > 0:
	# 		for staticBody in area2DNearby:
	# 			if staticBody.is_in_group("magnetrons"):
	# 				var space_state = get_world_2d().direct_space_state

	# 				var query = PhysicsRayQueryParameters2D.create(global_position, staticBody.global_position, 1)
	# 				var result = space_state.intersect_ray(query)
	# 				if result:
	# 					if result.collider.is_in_group("magnetrons"):
	# 						var distance = staticBody.global_position.distance_to(global_position)
	# 						closestDistance = min(closestDistance, distance)

	# 						distancesToMagnetrons[distance] = staticBody
	# 	if closestDistance > 0 and closestDistance != 100000.0:
	# 		pass
	# 	else:
	# 		isMagnettronPulling = false

	# Sucking towards closests visible magnetron in not orbitting near magnetron
	if Input.is_action_pressed("RMB") and not canUseSpaceJump:
		var area2DNearby = $MagnetronPullChecker.get_overlapping_bodies() as Array[CharacterBody2D]
		var distancesToMagnetrons := {}
		var closestDistance := 100000.0 # TODO fix condition

		if area2DNearby.size() > 0:
			for staticBody in area2DNearby:
				if staticBody.is_in_group("magnetrons"):
					var space_state = get_world_2d().direct_space_state

					var query = PhysicsRayQueryParameters2D.create(global_position, staticBody.global_position)
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
			isMagnettronPulling = true
			if not $MagnetronPullingSFX2D2.playing:
				$MagnetronPullingSFX2D2.play()

	player_moved.emit(velocity * _delta)

	# General movement
	var collision := move_and_collide(velocity * _delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		player_moved.emit(velocity * _delta)
		if not $BounceSFX2D.playing:
			$BounceSFX2D.play()
	
	rotation = global_position.direction_to(oldPosition).angle()


# When player enter magnetron zone, he can use space jump and orbits around the magnetron
func _on_player_entered_magnetron_zone(magnetron: CharacterBody2D, isCheckpoint: bool) -> void:
	$AnimatedSprite2D.play("idle")

	# No drawing of pull trajectory if came on orbit
	$Node/PullTrajectory.clear_points()
	$Node/PullTrajectory.hide()

	canUseSpaceJump = true
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

func _on_player_bonus_jump_pickup() -> void:
	canUseSpaceJumpBonus = true
	Engine.time_scale = 0.15
	await get_tree().create_timer(Engine.time_scale * 1.5).timeout
	Engine.time_scale = 1.


func hasSpaceJump() -> bool:
	return canUseSpaceJump or canUseSpaceJumpBonus

func resetSpaceJump() -> void:
	canUseSpaceJump = false
	canUseSpaceJumpBonus = false

func activateCheckpoint(magnetron: CharacterBody2D) -> void:
	if magnetronCheckpoint != magnetron:
		if magnetronCheckpoint != null:
			magnetronCheckpoint.deactivate_checkpoint()
		magnetron.activate_checkpoint(not isFirstCheckpoint)
		isFirstCheckpoint = false

		magnetronCheckpoint = currentMagnetron
		checkpointPosition = global_position
		checkpointAnglePosition = magnetron_initial_orbitting_angle
		checkpointOrbittingRadius = magnetron_orbitting_radius
		checkpoint_magnetron_orbitting_direction = magnetron_orbitting_direction

func on_death_reset() -> void:
	deathCount += 1

	# Player death effect
	var explosion_effect = explosion_effect_scene.instantiate()
	ParticleSystem.add_effect(explosion_effect, global_position)

	if magnetronCheckpoint != null:
		currentMagnetron = magnetronCheckpoint
		global_position = checkpointPosition
		magnetron_initial_orbitting_angle = checkpointAnglePosition
		magnetron_orbitting_radius = checkpointOrbittingRadius
		resetSpaceJump()
		velocity = Vector2.ZERO
	else:
		print("No checkpoint found")

# Draw trajectory till first collision or MAX_TRAJECTORY_POINTS
func updateTrajectory() -> void:
	# Same calculation like when mouse input is released
	var lastMousePos: Vector2 = get_global_mouse_position()
	var velocity_vector: Vector2 = (global_position - lastMousePos) * 2
	var finite_vector: Vector2 = velocity_vector.normalized() * clamp(velocity_vector.length(), MIN_SPACE_JUMP_SPEED, MAX_SPACE_JUMP_SPEED)
	
	%DirectionMarker.rotation = finite_vector.angle()
	%DirectionMarker.position = position
	%DirectionMarker.self_modulate = gradient.sample(finite_vector.length())
