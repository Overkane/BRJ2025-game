extends Control

signal return_to_main_menu


func _on_back_button_pressed() -> void:
	return_to_main_menu.emit()
