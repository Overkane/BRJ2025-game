extends Node2D

# Boss related
var currentBoss: CharacterBody2D
const boss1_scene := preload("res://scenes/bosses/boss_1.tscn")

var isBoss1Defeated := false
var isBoss2Defeated := false
var isBoss3Defeated := false


func _ready():
	for activator in get_tree().get_nodes_in_group("activators"):
		activator.body_entered.connect(_on_activator_body_entered.bind(activator))
	for trap in get_tree().get_nodes_in_group("traps"):
		trap.body_entered.connect(_on_player_hit)

	$Boss1/Boss1BlockerEnter/CollisionShape2D.set_deferred("disabled", true)
	$Boss2/Boss2BlockerEnter/CollisionShape2D.set_deferred("disabled", true)

func _input(event):
	if event.is_action_pressed("pause"):
		togglePauseMenu()


# Player entered boss 1 area
func _on_boss_1_area_enter_body_entered(body:Node2D) -> void:
	if currentBoss == null and not isBoss1Defeated:
		$Boss1/Boss1BlockerEnter.show()
		$Boss1/Boss1BlockerEnter/CollisionShape2D.set_deferred("disabled", false)
		
		var boss1 = boss1_scene.instantiate()
		boss1.global_position = $Boss1/Boss1SpawnPoint.global_position
		boss1.rotation = 3 * PI / 2 # Rotation to the endter area by default
		boss1.activate(body)
		boss1.boss_defeat.connect(_on_boss_defeat.bind(boss1))
		boss1.boss_reset.connect(_on_boss_reset.bind(boss1))
		# TODO what is the point of calling deferred? Editor debugger asked to add this
		call_deferred("add_child", boss1)

		currentBoss = boss1

func _on_boss_defeat(boss: CharacterBody2D) -> void:
	if boss is Boss1:
		$Boss1/Boss1BlockerExit.queue_free()
		boss.queue_free()
		isBoss1Defeated = true
	elif boss is Boss2:
		$Boss2/Boss2BlockerExit.queue_free()
		boss.queue_free()
		isBoss2Defeated = true
	# elif boss is Boss3:
	# 	$Boss3/Boss3BlockerExit.queue_free()

func _on_boss_reset(boss: CharacterBody2D) -> void:
	currentBoss = null
	boss.queue_free()
	if boss is Boss1:
		$Boss1/Boss1BlockerEnter.hide()
		$Boss1/Boss1BlockerEnter/CollisionShape2D.set_deferred("disabled", true)

		$Player.on_death_reset()
	elif boss is Boss2:
		$Boss2/Boss2BlockerEnter.hide()
		$Boss2/Boss2BlockerEnter/CollisionShape2D.set_deferred("disabled", true)

		$Player.on_death_reset()
	# elif boss is Boss3:
	# 	$Boss3/Boss3BlockerExit.hide()

# Traps
func _on_player_hit(_body: Node2D) -> void:
	if currentBoss != null:
		_on_boss_reset(currentBoss)
	else: 
		$Player.on_death_reset()

# Activators for tutorial destroy tiles nearby with help of invisible activator tiles
func _on_activator_body_entered(_body: Node2D, activator: Area2D) -> void:
	var cellPosition: Vector2i = $TileMapLayer.local_to_map(activator.get_position())
	destroyTileActivators(cellPosition)
	activator.queue_free()

func _on_resume_button_pressed() -> void:
	togglePauseMenu()

# Kills the player
func _on_reset_button_pressed() -> void:
	_on_player_hit($Player)
	togglePauseMenu()

# Can't implement cuz cross reference
# func _on_main_menu_button_pressed() -> void:
# 	pass

func _on_options_button_pressed() -> void:
	%OptionsMenuContainer.show()

func _on_options_menu_return_to_main_menu() -> void:
	%OptionsMenuContainer.hide()


func destroyTileActivators(cellPosition: Vector2i) -> void:
	$TileMapLayer.erase_cell(cellPosition)
	for cell in $TileMapLayer.get_surrounding_cells(cellPosition):
		var tileData: TileData = $TileMapLayer.get_cell_tile_data(cell)
		if tileData:
			if tileData.get_custom_data("isActivator"):
				destroyTileActivators(cell)
			else:
				$TileMapLayer.erase_cell(cell)
	
func togglePauseMenu() -> void:
	if not %PauseMenu.visible:
		get_tree().paused = true
		%PauseMenu.show()
	else:
		get_tree().paused = false
		%PauseMenu.hide()
