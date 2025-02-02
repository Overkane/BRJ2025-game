class_name Boss2 extends CharacterBody2D

signal boss_defeat
signal boss_reset

# General properties
var playerTarget: CharacterBody2D
var currentPhaseA := 0
var currentPhaseB := 0
var isBossARage := false
var isBossBRage := false
@onready var bossA := $Path2D/PathFollowBossA/Boss2A
@onready var bossB := $Path2D/PathFollowBossB/Boss2B
@onready var bossAPath := $Path2D/PathFollowBossA
@onready var bossBPath := $Path2D/PathFollowBossB

# Rotation mechanic
var bossSpeedOnPath2D := 30.

# Spells
const laser_beam_scene = preload("res://scenes/projectile/laser_beam.tscn")
const projectile_scene = preload("res://scenes/projectile/projectile.tscn")
const explosive_projectile_scene = preload("res://scenes/projectile/explosive_projectile.tscn")


func _ready() -> void:
	$Path2D/PathFollowBossA/Boss2A/WeakPointA1.body_entered.connect(_onWeakPointBodyEntered.bind($Path2D/PathFollowBossA/Boss2A/WeakPointA1, bossA))
	$Path2D/PathFollowBossA/Boss2A/WeakPointA2.body_entered.connect(_onWeakPointBodyEntered.bind($Path2D/PathFollowBossA/Boss2A/WeakPointA2, bossA))
	$Path2D/PathFollowBossB/Boss2B/WeakPointB1.body_entered.connect(_onWeakPointBodyEntered.bind($Path2D/PathFollowBossB/Boss2B/WeakPointB1, bossB))
	$Path2D/PathFollowBossB/Boss2B/WeakPointB2.body_entered.connect(_onWeakPointBodyEntered.bind($Path2D/PathFollowBossB/Boss2B/WeakPointB2, bossB))

	$Path2D/PathFollowBossA/Boss2A/AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_2d_bossA_animation_finished)

func _physics_process(delta: float) -> void:
	if bossA != null:
		bossAPath.progress += bossSpeedOnPath2D * delta
		$Path2D/PathFollowBossA/Boss2A/BlockersA.global_position = bossA.global_position
		$Path2D/PathFollowBossA/Boss2A/BlockersA.rotation += 0.6 * delta
	if bossB != null:
		bossBPath.progress += bossSpeedOnPath2D * delta
		$Path2D/PathFollowBossB/Boss2B/BlockersB.global_position = bossB.global_position
		$Path2D/PathFollowBossB/Boss2B/BlockersB.rotation -= 0.6 * delta


# Activated the boss after cutscene
func activate(player: Node2D) -> void:
	playerTarget = player
	currentPhaseA = 1
	currentPhaseB = 1
	bossABehaviourLoop()
	bossBBehaviourLoop()

func bossABehaviourLoop() -> void:
	var attack = randi_range(0, 1)
	if isBossBRage:
		pass
		# $Path2D/PathFollowBossB/Boss2B/AnimatedSprite2D.play("laserALL")
	else:
		if attack == 0:
			$Path2D/PathFollowBossA/Boss2A/AnimatedSprite2D.play("rocket_launcher")
		elif attack == 1:
			$Path2D/PathFollowBossA/Boss2A/AnimatedSprite2D.play("shotgun")

func bossBBehaviourLoop() -> void:
	var attack = randi_range(0, 1)
	if isBossBRage:
		$Path2D/PathFollowBossB/Boss2B/AnimatedSprite2D.play("laserALL")
	else:
		if attack == 0:
			$Path2D/PathFollowBossB/Boss2B/AnimatedSprite2D.play("laserTRBL")
		elif attack == 1:
			$Path2D/PathFollowBossB/Boss2B/AnimatedSprite2D.play("laserTLBR")

func shootA(animationName: String) -> void:
	var number_of_attacks = 2 if not isBossARage else 4 

	if animationName == "rocket_launcher":
		for i in number_of_attacks:
			var projectile = explosive_projectile_scene.instantiate()
			projectile.setup($Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position, playerTarget.global_position)
			projectile.player_hit.connect(on_player_death)
			add_sibling(projectile)

			await get_tree().create_timer(1.5).timeout

	elif animationName == "shotgun":
		for i in number_of_attacks:
			var projectile = projectile_scene.instantiate()
			projectile.setup($Path2D/PathFollowBossA/Boss2A/ShotPointShotgun.global_position, $Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position.direction_to(playerTarget.global_position))
			projectile.player_hit.connect(on_player_death)
			add_sibling(projectile)
			var projectile2 = projectile_scene.instantiate()
			projectile2.setup($Path2D/PathFollowBossA/Boss2A/ShotPointShotgun.global_position, $Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position.direction_to(playerTarget.global_position).rotated(PI/4))
			projectile2.player_hit.connect(on_player_death)
			add_sibling(projectile2)
			var projectile3 = projectile_scene.instantiate()
			projectile3.setup($Path2D/PathFollowBossA/Boss2A/ShotPointShotgun.global_position, $Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position.direction_to(playerTarget.global_position).rotated(-PI/4))
			projectile3.player_hit.connect(on_player_death)
			add_sibling(projectile3)
			var projectile4 = projectile_scene.instantiate()
			projectile4.setup($Path2D/PathFollowBossA/Boss2A/ShotPointShotgun.global_position, $Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position.direction_to(playerTarget.global_position).rotated(PI/6))
			projectile4.player_hit.connect(on_player_death)
			add_sibling(projectile4)
			var projectile5 = projectile_scene.instantiate()
			projectile5.setup($Path2D/PathFollowBossA/Boss2A/ShotPointShotgun.global_position, $Path2D/PathFollowBossA/Boss2A/ShotPointRocketLauncher.global_position.direction_to(playerTarget.global_position).rotated(-PI/6))
			projectile5.player_hit.connect(on_player_death)
			add_sibling(projectile5)

			await get_tree().create_timer(0.75).timeout

	bossABehaviourLoop()

func shootB(animationName: String) -> void:
	# TODO why rotation is so weird?
	var projectile = laser_beam_scene.instantiate()
	if animationName == "laserALL":
		projectile.setup($Path2D/PathFollowBossB/Boss2B/ShootPointTL.position, PI / 4)
		projectile.player_hit.connect(on_player_death)
		bossB.add_child(projectile)
		var projectile2 = laser_beam_scene.instantiate()
		projectile2.setup($Path2D/PathFollowBossB/Boss2B/ShootPointBR.position, PI / 4 + PI)
		projectile2.player_hit.connect(on_player_death)
		bossB.add_child(projectile2)
		var projectile3 = laser_beam_scene.instantiate()
		projectile3.setup($Path2D/PathFollowBossB/Boss2B/ShootPointTR.position, PI / 4 + PI / 2)
		projectile3.player_hit.connect(on_player_death)
		bossB.add_child(projectile3)
		var projectile4 = laser_beam_scene.instantiate()
		projectile4.setup($Path2D/PathFollowBossB/Boss2B/ShootPointBL.position, PI / 4 + PI / 2 + PI)
		projectile4.player_hit.connect(on_player_death)
		bossB.add_child(projectile4)
	elif animationName == "laserTLBR":
		projectile.setup($Path2D/PathFollowBossB/Boss2B/ShootPointTL.position, PI / 4)
		projectile.player_hit.connect(on_player_death)
		bossB.add_child(projectile)
		var projectile2 = laser_beam_scene.instantiate()
		projectile2.setup($Path2D/PathFollowBossB/Boss2B/ShootPointBR.position, PI / 4 + PI)
		projectile2.player_hit.connect(on_player_death)
		bossB.add_child(projectile2)
	elif animationName == "laserTRBL":
		projectile.setup($Path2D/PathFollowBossB/Boss2B/ShootPointTR.position, PI / 4 + PI / 2)
		projectile.player_hit.connect(on_player_death)
		bossB.add_child(projectile)
		var projectile2 = laser_beam_scene.instantiate()
		projectile2.setup($Path2D/PathFollowBossB/Boss2B/ShootPointBL.position, PI / 4 + PI / 2 + PI)
		projectile2.player_hit.connect(on_player_death)
		bossB.add_child(projectile2)
	projectile.laser_beam_end.connect(bossBBehaviourLoop)

# Player died to a boss
func on_player_death():
	# Reset the boss without actually defeating it
	boss_reset.emit()


func _onWeakPointBodyEntered(_body: Node2D, weakPointNode: Area2D, boss: CharacterBody2D) -> void:
	weakPointNode.destroy()

	# 3rd phase means boss is down, cuz 2 weak point per each one
	if boss == bossA:
		currentPhaseA += 1
		if currentPhaseA == 3:
			bossA.queue_free()
	elif boss == bossB:
		currentPhaseB += 1
		if currentPhaseB == 3:
			bossB.queue_free()

	if currentPhaseA == 3 and currentPhaseB == 3:
		boss_defeat.emit()
	else:
		# If one of the bosses dies, another one goes to rage
		if currentPhaseA == 3:
			isBossBRage = true
		elif currentPhaseB == 3:
			isBossARage = true

		# Bosses go faster on path 2D
		bossSpeedOnPath2D *= 1.15		

# Boss A shoots with shotgun and rocket launcher
func _on_animated_sprite_2d_bossA_animation_finished() -> void:
	shootA($Path2D/PathFollowBossA/Boss2A/AnimatedSprite2D.animation)

# Boss B just shoots lasers in different directions
func _on_animated_sprite_2d_bossB_animation_finished() -> void:
	shootB($Path2D/PathFollowBossB/Boss2B/AnimatedSprite2D.animation)
