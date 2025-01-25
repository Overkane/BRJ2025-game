extends CharacterBody2D
# TODO main cannon, side cannons

signal playerHit

# General properties
var currentPhase := 0
var playerTarget: CharacterBody2D

# Rotation mechanic
var isRotating := false
var rotationSpeed := 0.0
var rotationDirection := 1

# Side-cannon mechanic
@onready var sideCannonsPositions: Array[Marker2D] = [$SideCannonPoint,$SideCannonPoint2,$SideCannonPoint3]
const projectile_scene = preload("res://scenes/projectile/projectile.tscn")


func _ready() -> void:
	$WeakPoint1.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint1))
	$WeakPoint2.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint2))
	$WeakPoint3.body_entered.connect(_onWeakPointBodyEntered.bind($WeakPoint3))

func _process(delta):
	if isRotating:
		# PI/2 cuz model looks on -y axis, not x axis.
		var angleToPlayer = global_position.angle_to_point(playerTarget.global_position) + PI / 2
		rotation = lerp_angle(rotation, angleToPlayer, rotationSpeed * delta)
		

# Activated the boss after cutscene
func activate(player: Node2D) -> void:
	playerTarget = player
	currentPhase = 1
	startBossRotation()
	bossBehaviourLoop()

func bossBehaviourLoop() -> void:
	$AnimatedSprite2D.play("sideCannon")

func switchBossPhase() -> void:
	currentPhase += 1
	$AnimatedSprite2D.speed_scale = 0.55 + currentPhase * 0.25
	rotationSpeed += 0.05

func startBossRotation() -> void:
	isRotating = true
	rotationSpeed = 0.1
	rotationDirection = 1

func activateSideCannons() -> void:
	for cannon in sideCannonsPositions:
		var projectile = projectile_scene.instantiate()
		projectile.setup(cannon.global_position, Vector2.RIGHT.rotated(randf_range(0, 2*PI)))
		projectile.body_entered.connect(_onProjectileBodyEntered.bind(projectile))
		add_sibling(projectile)

	bossBehaviourLoop()

func activateMainCannon() -> void:
	pass
	bossBehaviourLoop()


func _onWeakPointBodyEntered(_body: Node2D, weakPointNode: Area2D) -> void:
	weakPointNode.queue_free()
	if currentPhase == 3:
		queue_free()
	else:
		switchBossPhase()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "sideCannon":
		activateSideCannons()
	elif $AnimatedSprite2D.animation == "mainCannon":
		activateMainCannon()

func _onProjectileBodyEntered(body: Node2D, projectile: Area2D) -> void:
	if body.is_in_group("player"):
		playerHit.emit()
	projectile.queue_free()
