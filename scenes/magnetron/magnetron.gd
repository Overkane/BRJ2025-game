extends CharacterBody2D

signal player_entered_magnetron_zone

@export var isCheckpoint := false


func _ready():
	# If this is a checkpoint, then switch sprite to checkpoint one
	if isCheckpoint:
		$Area2D/MagnetronSprite.hide()
		$Area2D/MagnetronCheckpointDeactivatedSprite2.show()


func _on_area_2d_body_entered(body:Node2D) -> void:
	var connectedFunction := Callable(body, "_on_player_entered_magnetron_zone")
	if not player_entered_magnetron_zone.is_connected(connectedFunction):
		player_entered_magnetron_zone.connect(connectedFunction.bind(self, isCheckpoint))
	player_entered_magnetron_zone.emit()

func deactivate_checkpoint():
	$Area2D/MagnetronCheckpointActivatedSprite.hide()
	$Area2D/MagnetronCheckpointDeactivatedSprite2.show()

func activate_checkpoint():
	$Area2D/MagnetronCheckpointActivatedSprite.show()
	$Area2D/MagnetronCheckpointDeactivatedSprite2.hide()