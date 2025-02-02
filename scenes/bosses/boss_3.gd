class_name Boss3 extends CharacterBody2D

signal boss_defeat
signal boss_reset

static var first_time_on_boss := true

# General properties
var isLeftEyeCasting := false
var isRightEyeACasting := false
var leftEyeSpeed := 50
var rightEyeSpeed := 25


var isActivated := false
var currentPhase := 0
var playerTarget: CharacterBody2D
var hits_to_awake_the_boss := 3
var currenthitsToAwakeTheBoss := 0
@onready var exitBlockersArray := [$Boss3BlockerExit1, $Boss3BlockerExit2, $Boss3BlockerExit3, $Boss3BlockerExit4, $Boss3BlockerExit5]
@onready var boss_left_eye: AnimatedSprite2D = $BossLeftEye
@onready var boss_right_eye: AnimatedSprite2D = $BossRightEye
@onready var left_eye_shooting_points: Array = [$BossLeftEye/BarrageShootingPoint,$BossLeftEye/BarrageShootingPoint2,$BossLeftEye/BarrageShootingPoint3,$BossLeftEye/BarrageShootingPoint4]
@onready var right_eye_shooting_points: Array = [$BossRightEye/BarrageShootingPoint,$BossRightEye/BarrageShootingPoint2,$BossRightEye/BarrageShootingPoint3,$BossRightEye/BarrageShootingPoint4]
# Rotation mechanic
var rotationSpeed := 0.06

# Projectiles
const projectile_scene = preload("res://scenes/projectile/projectile_boss3.tscn")
const laser_beam_scene = preload("res://scenes/projectile/laser_beam_boss3.tscn")

func _ready() -> void:
	$WeakPoint1.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint1))
	$WeakPoint2.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint2))
	$WeakPoint3.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint3))
	$WeakPoint4.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint4))
	$WeakPoint5.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint5))
	$WeakPoint6.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint6))

	$Boss3AreaEnter.body_entered.connect(close_front_door)

	boss_right_eye.flip_h = true

	boss_right_eye.animation_finished.connect(_on_animated_sprite_2d_animation_finished.bind(boss_right_eye))
	boss_left_eye.animation_finished.connect(_on_animated_sprite_2d_animation_finished.bind(boss_left_eye))

	$AnimationPlayer.animation_finished.connect(_on_boss_awake)

func _physics_process(delta):
	if not first_time_on_boss:
		hits_to_awake_the_boss = 1
	else:
		hits_to_awake_the_boss = 3

	if isActivated:
		rotation += rotationSpeed * delta
		if not isLeftEyeCasting:
			# TODO how it works?
			var eyePos = $BossLeftEye.global_position
			var playerPos := playerTarget.global_position
			var eyeLine = ($LeftEyeMarkerBottom.global_position - $LeftEyeMarkerTop.global_position).normalized()

			var shift = eyeLine.dot(playerPos - eyePos)

			$BossLeftEye.global_position = $BossLeftEye.global_position.move_toward(eyePos + eyeLine * shift * delta, leftEyeSpeed)
		if not isRightEyeACasting:
			var eyePos = $BossRightEye.global_position
			var playerPos := playerTarget.global_position
			var eyeLine = ($RightEyeMarkerBottom.global_position - $RightEyeMarkerTop.global_position).normalized()

			var shift = eyeLine.dot(playerPos - eyePos)
			
			$BossRightEye.global_position = $BossRightEye.global_position.move_toward(eyePos + eyeLine * shift * delta, rightEyeSpeed)



# Activated the boss after cutscene
func activate(player: Node2D) -> void:
	playerTarget = player
	currentPhase = 1
	isActivated = false # Activation from button press, that is boss init
	$Boss3BlockerEnter.hide()
	$Boss3BlockerEnter/CollisionShape2D.set_deferred("disabled", true)

func bossBehaviourLoop(bossEye: AnimatedSprite2D) -> void:
	var attack_var := randi_range(0,1)
	if attack_var == 0:
		bossEye.play("laser")
	elif attack_var == 1:
		bossEye.play("barrage")

func switchBossPhase() -> void:
	currentPhase += 1
	rotationSpeed += 0.01

func barrage(bossEye: AnimatedSprite2D) -> void:
	var projectile_point_array: Array
	var sound_player: AudioStreamPlayer2D
	if bossEye == boss_left_eye:
		isLeftEyeCasting = true
		projectile_point_array = left_eye_shooting_points
		sound_player = $ProjectileShotLeftEyeSFX2D
	else:
		isRightEyeACasting = true
		projectile_point_array = right_eye_shooting_points
		sound_player = $ProjectileShotRightEyeSFX2D2

	projectile_point_array.shuffle()

	for shooting_point in projectile_point_array:
		var projectile = projectile_scene.instantiate()
		projectile.setup(shooting_point.global_position, bossEye.global_position.direction_to(playerTarget.global_position))
		projectile.body_entered.connect(_onProjectileBodyEntered.bind(projectile))
		add_sibling(projectile)
		sound_player.play()

		await get_tree().create_timer(1.25).timeout

	if bossEye == boss_left_eye:
		isLeftEyeCasting = false
	else:
		isRightEyeACasting = false
	
	bossEye.play("idle")
	await get_tree().create_timer(randf_range(4,6)).timeout
	
	bossBehaviourLoop(bossEye)

func laser(bossEye: AnimatedSprite2D) -> void:
	var laser_shooting_point: Vector2
	var shooting_angle: float
	if bossEye == boss_left_eye:
		isLeftEyeCasting = true
		laser_shooting_point = $BossLeftEye/LaserShootingPoint.position
		shooting_angle = 0
	else:
		isRightEyeACasting = true
		laser_shooting_point = $BossRightEye/LaserShootingPoint.position
		shooting_angle = PI

	var projectile = laser_beam_scene.instantiate()
	projectile.setup(laser_shooting_point, shooting_angle)
	projectile.player_hit.connect(on_player_death)
	bossEye.add_child(projectile)

	$LaserSFX2D.play()

	# Wait laser duration
	await get_tree().create_timer(5).timeout

	if $LaserSFX2D.playing:
		$LaserSFX2D.stop()

	if bossEye == boss_left_eye:
		isLeftEyeCasting = false
	else:
		isRightEyeACasting = false

	bossEye.play("idle")
	await get_tree().create_timer(randf_range(4,6)).timeout

	bossBehaviourLoop(bossEye)

# Player died to a boss
func on_player_death():
	# Reset the boss without actually defeating it
	boss_reset.emit()

func close_front_door(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Boss3BlockerEnter.show()
		$Boss3BlockerEnter/CollisionShape2D.set_deferred("disabled", false)


func _onWeakPointBodyEntered(_body: Node2D, weakPointNode: Area2D) -> void:
	currenthitsToAwakeTheBoss += 1
	if currenthitsToAwakeTheBoss >= hits_to_awake_the_boss:
		# Each button destroys 1 blocker to final button
		if not exitBlockersArray.is_empty():
			exitBlockersArray.pop_front().queue_free()

		if currenthitsToAwakeTheBoss == hits_to_awake_the_boss:
			if first_time_on_boss:
				# Boss awakening
				$AnimationPlayer.play("boss_awake")
				$BossAwakeSFX2D.play()
			else:
				boss_right_eye.self_modulate = Color.WHITE
				boss_right_eye.scale = Vector2(1,1)
				boss_left_eye.self_modulate = Color.WHITE
				boss_left_eye.scale = Vector2(1,1)
				_on_boss_awake("boss_awake")

		first_time_on_boss = false
		weakPointNode.destroy()
		if currentPhase == 6:
			boss_defeat.emit()
		else:
			switchBossPhase()
	else:
		$ButtonShakeSFX2D.play()
		Globals.shake_camera()

func _on_boss_awake(_animationName: String) -> void:
	isActivated = true
	# Boss start to act
	$Boss3BlockerFullOpen.hide()
	$Boss3BlockerFullOpen/CollisionShape2D.set_deferred("disabled", true)
	$Boss3BlockerFullOpen2.hide()
	$Boss3BlockerFullOpen2/CollisionShape2D.set_deferred("disabled", true)
	bossBehaviourLoop(boss_left_eye)
	bossBehaviourLoop(boss_right_eye)

func _on_animated_sprite_2d_animation_finished(bossEye: AnimatedSprite2D) -> void:
	if bossEye.animation == "laser":
		laser(bossEye)
	if bossEye.animation == "barrage":
		barrage(bossEye)

func _onProjectileBodyEntered(body: Node2D, projectile: Area2D) -> void:
	if body.is_in_group("player"):
		on_player_death()
		projectile.queue_free()
	# TODO projectiles will infinite
