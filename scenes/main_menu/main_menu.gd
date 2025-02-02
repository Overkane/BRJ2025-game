extends Control

@onready var _menu = $Menu
@onready var _credits = $Credits
@onready var _options_menu = $OptionsMenu
@onready var _quit_button = $Menu/MarginContainer4/QuitButton

const WORLD_SCENE := preload("res://scenes/world/world.tscn")

enum MenuOptions { MAIN_MENU, OPTIONS, CREDITS }


func _ready() -> void:
	if OS.has_feature("web"):
		_quit_button.hide()
	$OptionsMenu.set_default_settings()
	$Menu/MarginContainer/PlayButton.pressed.connect(_on_button_pressed_sfx)
	$Menu/MarginContainer/PlayButton.mouse_entered.connect(_on_button_hover_sfx)
	$Menu/MarginContainer2/OptionsButton.pressed.connect(_on_button_pressed_sfx)
	$Menu/MarginContainer2/OptionsButton.mouse_entered.connect(_on_button_hover_sfx)
	$Menu/MarginContainer3/CreditsButton.pressed.connect(_on_button_pressed_sfx)
	$Menu/MarginContainer3/CreditsButton.mouse_entered.connect(_on_button_hover_sfx)
	$Menu/MarginContainer4/QuitButton.pressed.connect(_on_button_pressed_sfx)
	$Menu/MarginContainer4/QuitButton.mouse_entered.connect(_on_button_hover_sfx)

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

func _on_button_pressed_sfx() -> void:
	$PressUISFX2D.play()
	
func _on_button_hover_sfx() -> void:
	$HoverUISFX2D.play()


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
