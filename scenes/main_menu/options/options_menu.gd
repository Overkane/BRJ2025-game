extends Control

signal return_to_main_menu

@onready var _mouse_lock_checkbox := $PanelContainer/MarginContainer/VBoxContainer/SplitContainer/VideoSettingsContainer/MouseLockCheckBox

@onready var _master_slider := $PanelContainer/MarginContainer/VBoxContainer/SplitContainer/MarginContainer/AudioSettingsContainer/MarginContainer/MasterSlider
@onready var _music_slider := $PanelContainer/MarginContainer/VBoxContainer/SplitContainer/MarginContainer/AudioSettingsContainer/MarginContainer2/MusicSlider
@onready var _sfx_slider := $PanelContainer/MarginContainer/VBoxContainer/SplitContainer/MarginContainer/AudioSettingsContainer/MarginContainer3/SFXSlider

enum SoundBuses { MASTER, MUSIC, SFX }


func _ready():
	_mouse_lock_checkbox.set_pressed_no_signal(GameSettings.isMouseLock)

	_master_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.MASTER)))
	_music_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.MUSIC)))
	_sfx_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.SFX)))

	# Seems that html5 doesn't support mouse confine mode
	if OS.has_feature("web"):
		_mouse_lock_checkbox.hide()

func _on_check_box_pressed() -> void:
	if DisplayServer.mouse_get_mode() != DisplayServer.MOUSE_MODE_CONFINED:
		GameSettings.isMouseLock = true
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	else:
		GameSettings.isMouseLock = false
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _on_master_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.MASTER, linear_to_db(value))

func _on_music_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.MUSIC, linear_to_db(value))

func _on_sfx_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.SFX, linear_to_db(value))

func _on_back_button_pressed() -> void:
	return_to_main_menu.emit()


func set_default_settings() -> void:
	GameSettings.isMouseLock = true
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	_mouse_lock_checkbox.set_pressed_no_signal(GameSettings.isMouseLock)
	
	var default_sound_volume = 0.75
	AudioServer.set_bus_volume_db(SoundBuses.MASTER, linear_to_db(default_sound_volume))
	_master_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.MASTER)))
