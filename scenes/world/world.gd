extends Node2D

var boss1: CharacterBody2D
const boss1_scene := preload("res://scenes/bosses/boss_1.tscn")


func _ready():
	for activator in get_tree().get_nodes_in_group("activators"):
		activator.body_entered.connect(_on_activator_body_entered.bind(activator))
	for trap in get_tree().get_nodes_in_group("traps"):
		trap.body_entered.connect(_on_player_hit)


# Player entered boss 1 area
func _on_boss_1_area_enter_body_entered(body:Node2D) -> void:
	if boss1 != null:
		boss1.queue_free()
	
	boss1 = boss1_scene.instantiate()
	boss1.global_position = $Boss1SpawnPoint.global_position
	boss1.rotation = 3 * PI / 2 # Rotation to the endter area by default
	boss1.playerHit.connect(_on_player_hit)
	boss1.activate(body)
	add_child(boss1)

func _on_player_hit(_body: Node2D) -> void:
	$Player.on_death_reset()

# Activators for tutorial destroy tiles nearby with help of invisible activator tiles
func _on_activator_body_entered(_body: Node2D, activator: Area2D) -> void:
	var cellPosition: Vector2i = $TileMapLayer.local_to_map(activator.get_position())
	destroyTileActivators(cellPosition)
	activator.queue_free()


func destroyTileActivators(cellPosition: Vector2i) -> void:
	$TileMapLayer.erase_cell(cellPosition)
	for cell in $TileMapLayer.get_surrounding_cells(cellPosition):
		var tileData: TileData = $TileMapLayer.get_cell_tile_data(cell)
		if tileData:
			if tileData.get_custom_data("isActivator"):
				destroyTileActivators(cell)
			else:
				$TileMapLayer.erase_cell(cell)
	