extends Control

const CURSOR_NORMAL := preload("res://assets/Tilesets/Mouse/normal_mouse.png")
const CURSOR_HOVER := preload("res://assets/Tilesets/Mouse/hover_mouse.png")
const CURSOR_CLICK := preload("res://assets/Tilesets/Mouse/click_mouse.png")

@onready var jugar_button: Button = $CenterContainer/VBoxContainer/Jugar
@onready var opciones_button: Button = $CenterContainer/VBoxContainer/Opciones
@onready var salir_button: Button = $CenterContainer/VBoxContainer/Salir
@onready var tutorial_dialog: ConfirmationDialog = $TutorialDialog

var config_path = "user://config.cfg"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	
	# Asegurar que el fade esté oculto al inicio
	var fade = get_node_or_null("/root/Fade")
	if is_instance_valid(fade):
		fade.color_rect.hide()
	
	jugar_button.pressed.connect(_on_jugar_pressed)
	opciones_button.pressed.connect(_on_opciones_pressed)
	salir_button.pressed.connect(_on_salir_pressed)
	
	for button in [jugar_button, opciones_button, salir_button]:
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
		button.button_down.connect(_on_button_pressed.bind(button))
		button.button_up.connect(_on_button_released.bind(button))
	
	tutorial_dialog.confirmed.connect(_on_tutorial_accepted)
	tutorial_dialog.close_requested.connect(_on_tutorial_closed)
	tutorial_dialog.get_cancel_button().pressed.connect(_on_tutorial_rejected)

func _on_jugar_pressed():
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	
	var config = ConfigFile.new()
	var has_done_tutorial = config.load(config_path) == OK && config.get_value("tutorial", "completed", false)
	
	if has_done_tutorial:
		tutorial_dialog.dialog_text = "¿Quieres repetir el tutorial?"
	else:
		tutorial_dialog.dialog_text = "¿Quieres hacer el tutorial?"
	
	tutorial_dialog.popup_centered()

func _on_tutorial_accepted():
	var fade = get_node_or_null("/root/Fade")
	if is_instance_valid(fade):
		await fade.fade_in(0.5)
	
	var config = ConfigFile.new()
	config.load(config_path)
	config.set_value("tutorial", "should_run", true)
	config.save(config_path)
	
	fade.reset_color_rect()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_tutorial_rejected():
	var fade = get_node_or_null("/root/Fade")
	if is_instance_valid(fade):
		await fade.fade_in(0.5)
	
	var config = ConfigFile.new()
	config.load(config_path)
	config.set_value("tutorial", "should_run", false)
	config.save(config_path)
	
	get_tree().change_scene_to_file("res://scenes/map.tscn")
	
func _on_tutorial_closed():
	tutorial_dialog.hide()

func _on_opciones_pressed():
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")

func _on_salir_pressed():
	get_tree().quit()

func _on_button_hovered(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_HOVER)
	button.scale = Vector2(1.05, 1.05)

func _on_button_unhovered(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	button.scale = Vector2(1.0, 1.0)

func _on_button_pressed(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_CLICK)
	button.scale = Vector2(0.95, 0.95)

func _on_button_released(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_HOVER)
	button.scale = Vector2(1.05, 1.05)
