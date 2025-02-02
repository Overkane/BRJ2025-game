extends Control

signal return_to_main_menu


func _on_back_button_pressed() -> void:
	$PressUISFX2D.play()
	return_to_main_menu.emit()

func _on_back_button_mouse_entered() -> void:
	$HoverUISFX2D.play()
