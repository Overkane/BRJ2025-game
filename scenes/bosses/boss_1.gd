class_name Boss1 extends CharacterBody2D

signal boss_defeat
signal boss_reset

# General properties
var currentPhase := 0
var playerTarget: CharacterBody2D
var attackCounter := 0

# Rotation mechanic
var rotationSpeed := 0.25

# Side-cannon mechanic
const projectile_scene = preload("res://scenes/projectile/projectile.tscn")
const explosive_projectile_scene = preload("res://scenes/projectile/explosive_projectile.tscn")


func _ready() -> void:
	$WeakPoint1.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint1))
	$WeakPoint2.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint2))
	$WeakPoint3.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint3))

func _process(delta):
	rotation += rotationSpeed * delta
		

# Activated the boss after cutscene
func activate(player: Node2D) -> void:
	playerTarget = player
	currentPhase = 1
	bossBehaviourLoop()

func bossBehaviourLoop() -> void:
	attackCounter += 1
	if attackCounter % 3 == 0 and currentPhase >= 2:
		$AnimatedSprite2D.play("shoot_explosion")
	else:
		$AnimatedSprite2D.play("shoot")


func switchBossPhase() -> void:
	currentPhase += 1
	$AnimatedSprite2D.speed_scale = 0.5 + currentPhase * 0.2
	rotationSpeed += 0.25

func shoot() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position))
	projectile.player_hit.connect(on_player_death)
	add_sibling(projectile)
	if currentPhase == 3:
		var projectile2 = projectile_scene.instantiate()
		projectile2.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(PI/4))
		projectile2.player_hit.connect(on_player_death)
		add_sibling(projectile2)
		var projectile3 = projectile_scene.instantiate()
		projectile3.setup($ShootPoint.global_position, position.direction_to(playerTarget.global_position).rotated(-PI/4))
		projectile3.player_hit.connect(on_player_death)
		add_sibling(projectile3)

	bossBehaviourLoop()

func explosive_shot() -> void:
	var projectile = explosive_projectile_scene.instantiate()
	projectile.setup($ShootPoint.global_position, playerTarget.global_position)
	projectile.player_hit.connect(on_player_death)
	add_sibling(projectile)

	bossBehaviourLoop()

# Player died to a boss
func on_player_death():
	# Reset the boss without actually defeating it
	boss_reset.emit()


func _onWeakPointBodyEntered(_body: Node2D, weakPointNode: Area2D) -> void:
	weakPointNode.destroy()
	if currentPhase == 3:
		boss_defeat.emit()
	else:
		switchBossPhase()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "shoot":
		shoot()
	elif $AnimatedSprite2D.animation == "shoot_explosion":
		explosive_shot()

func _on_damage_area_body_entered(_body:Node2D) -> void:
	on_player_death()
