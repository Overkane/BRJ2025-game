extends CharacterBody2D

signal player_entered_magnetron_zone


func _on_area_2d_body_entered(body:Node2D) -> void:
	var connectedFunction := Callable(body, "_on_player_entered_magnetron_zone")
	if not player_entered_magnetron_zone.is_connected(connectedFunction):
		player_entered_magnetron_zone.connect(connectedFunction.bind(self))
	player_entered_magnetron_zone.emit()
