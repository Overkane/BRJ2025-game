extends CanvasLayer

@export var boss_arena: PackedScene 

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(boss_arena)
func _on_quit_button_pressed() -> void:
	get_tree().quit()
