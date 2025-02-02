class_name Boss3 extends CharacterBody2D

signal boss_defeat
signal boss_reset

# General properties
var isLeftEyeCasting := false
var isRightEyeACasting := false

var isActivated := false
var currentPhase := 0
var playerTarget: CharacterBody2D
const HITS_TO_AWAKE_THE_BOSS := 1
# const HITS_TO_AWAKE_THE_BOSS := 3
var currenthitsToAwakeTheBoss := 0
@onready var exitBlockersArray := [$Boss3BlockerExit1, $Boss3BlockerExit2, $Boss3BlockerExit3, $Boss3BlockerExit4, $Boss3BlockerExit5]
@onready var boss_left_eye: AnimatedSprite2D = $BossLeftEye
@onready var boss_right_eye: AnimatedSprite2D = $BossRightEye

# Rotation mechanic
var rotationSpeed := 0.06


func _ready() -> void:
	$WeakPoint1.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint1))
	$WeakPoint2.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint2))
	$WeakPoint3.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint3))
	$WeakPoint4.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint4))
	$WeakPoint5.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint5))
	$WeakPoint6.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint6))

	$Boss3AreaEnter.body_entered.connect(close_front_door)

	boss_right_eye.animation_finished.connect(_on_animated_sprite_2d_animation_finished.bind(boss_right_eye))
	boss_left_eye.animation_finished.connect(_on_animated_sprite_2d_animation_finished.bind(boss_left_eye))

func _physics_process(delta):
	if isActivated:
		rotation += rotationSpeed * delta
		if not isLeftEyeCasting:
			# TODO how it works?
			var eyePos = $BossLeftEye.global_position
			var playerPos := playerTarget.global_position
			var eyeLine = ($LeftEyeMarkerBottom.global_position - $LeftEyeMarkerTop.global_position).normalized()

			var shift = eyeLine.dot(playerPos - eyePos)

			$BossLeftEye.global_position = eyePos + eyeLine * shift * delta
		if not isLeftEyeCasting:
			var eyePos = $BossRightEye.global_position
			var playerPos := playerTarget.global_position
			var eyeLine = ($RightEyeMarkerBottom.global_position - $RightEyeMarkerTop.global_position).normalized()

			var shift = eyeLine.dot(playerPos - eyePos)

			$BossRightEye.global_position = eyePos + eyeLine * shift * delta



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

func laser() -> void:
	pass
	# var projectile = projectile_scene.instantiate()
	# projectile.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position))
	# projectile.body_entered.connect(_onProjectileBodyEntered.bind(projectile))
	# add_sibling(projectile)
	# if currentPhase == 3:
	# 	var projectile2 = projectile_scene.instantiate()
	# 	projectile2.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(PI/4))
	# 	projectile2.body_entered.connect(_onProjectileBodyEntered.bind(projectile2))
	# 	add_sibling(projectile2)
	# 	var projectile3 = projectile_scene.instantiate()
	# 	projectile3.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(-PI/4))
	# 	projectile3.body_entered.connect(_onProjectileBodyEntered.bind(projectile3))
	# 	add_sibling(projectile3)

	# bossBehaviourLoop()

func barrage() -> void:
	pass
	# var projectile = projectile_scene.instantiate()
	# projectile.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position))
	# projectile.body_entered.connect(_onProjectileBodyEntered.bind(projectile))
	# add_sibling(projectile)
	# if currentPhase == 3:
	# 	var projectile2 = projectile_scene.instantiate()
	# 	projectile2.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(PI/4))
	# 	projectile2.body_entered.connect(_onProjectileBodyEntered.bind(projectile2))
	# 	add_sibling(projectile2)
	# 	var projectile3 = projectile_scene.instantiate()
	# 	projectile3.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(-PI/4))
	# 	projectile3.body_entered.connect(_onProjectileBodyEntered.bind(projectile3))
	# 	add_sibling(projectile3)

	# bossBehaviourLoop()

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
	if currenthitsToAwakeTheBoss >= HITS_TO_AWAKE_THE_BOSS:
		# Each button destroys 1 blocker to final button
		if not exitBlockersArray.is_empty():
			exitBlockersArray.pop_front().queue_free()

		if currenthitsToAwakeTheBoss == HITS_TO_AWAKE_THE_BOSS:
			# Boss awakening
			$Boss3BlockerFullOpen.hide()
			$Boss3BlockerFullOpen/CollisionShape2D.set_deferred("disabled", true)
			$Boss3BlockerFullOpen2.hide()
			$Boss3BlockerFullOpen2/CollisionShape2D.set_deferred("disabled", true)
			$BossLeftEye.show()
			$BossRightEye.show()
			bossBehaviourLoop(boss_left_eye)
			bossBehaviourLoop(boss_right_eye)

		weakPointNode.destroy()
		isActivated = true
		if currentPhase == 6:
			boss_defeat.emit()
		else:
			switchBossPhase()
	else:
		$ButtonShakeSFX2D.play()

func _on_animated_sprite_2d_animation_finished(bossEye: AnimatedSprite2D) -> void:
	if bossEye.animation == "laser":
		laser()
	if bossEye.animation == "barrage":
		barrage()

# func _onProjectileBodyEntered(body: Node2D, projectile: Area2D) -> void:
# 	if body.is_in_group("player"):
# 		on_player_death()
# 	projectile.queue_free()

