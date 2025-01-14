extends Control

signal return_to_main_menu

@onready var _master_slider = $MarginContainer/VBoxContainer/SplitContainer/AudioSettingsContainer/MarginContainer/MasterSlider
@onready var _music_slider = $MarginContainer/VBoxContainer/SplitContainer/AudioSettingsContainer/MarginContainer2/MusicSlider
@onready var _sfx_slider = $MarginContainer/VBoxContainer/SplitContainer/AudioSettingsContainer/MarginContainer3/SFXSlider

enum SoundBuses { MASTER, MUSIC, SFX }


func _ready():
	_master_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.MASTER)))
	_music_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.MUSIC)))
	_sfx_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBuses.SFX)))


func _on_master_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.MASTER, linear_to_db(value))

func _on_music_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.MUSIC, linear_to_db(value))

func _on_sfx_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(SoundBuses.SFX, linear_to_db(value))

func _on_back_button_pressed() -> void:
	return_to_main_menu.emit()
