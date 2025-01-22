extends Control

@onready var _menu = $Menu
@onready var _credits = $Credits
@onready var _options_menu = $OptionsMenu
@onready var _quit_button = $Menu/QuitButton

const WORLD_SCENE := preload("res://scenes/world/world.tscn")

enum MenuOptions { MAIN_MENU, OPTIONS, CREDITS }


func _ready() -> void:
	if OS.has_feature("web"):
		_quit_button.hide()
	$OptionsMenu.set_default_audio_settings()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD_SCENE)

func _on_options_button_pressed() -> void:
	switch_menu_option(MenuOptions.OPTIONS)

func _on_options_menu_return_to_main_menu() -> void:
	switch_menu_option(MenuOptions.MAIN_MENU)

func _on_credits_button_pressed() -> void:
	switch_menu_option(MenuOptions.CREDITS)

func _on_credits_return_to_main_menu() -> void:
	switch_menu_option(MenuOptions.MAIN_MENU)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func switch_menu_option(menu_option: MenuOptions):
	if menu_option == MenuOptions.MAIN_MENU:
		_menu.show()
		_options_menu.hide()
		_credits.hide()
	elif  menu_option == MenuOptions.OPTIONS:
		_menu.hide()
		_options_menu.show()
		_credits.hide()
	elif menu_option == MenuOptions.CREDITS:
		_menu.hide()
		_options_menu.hide()
		_credits.show()
