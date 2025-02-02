extends Area2D

signal player_bonus_jump_pickup


# Only player can interact with it
# After pickup it disappears for short time, then respawns
func _on_body_entered(body:Node2D) -> void:
	var connectedFunction := Callable(body, "_on_player_bonus_jump_pickup")
	if not player_bonus_jump_pickup.is_connected(connectedFunction):
		player_bonus_jump_pickup.connect(connectedFunction)
	player_bonus_jump_pickup.emit()
	
	$PickupSFX2D.play()
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(5.).timeout
	show()
	$CollisionShape2D.set_deferred("disabled", false)
