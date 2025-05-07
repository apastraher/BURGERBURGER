extends Control

# Precarga de texturas de cursor (usa constantes para mejor legibilidad)
const CURSOR_NORMAL := preload("res://assets/Tilesets/Mouse/normal_mouse.png")
const CURSOR_HOVER := preload("res://assets/Tilesets/Mouse/hover_mouse.png")
const CURSOR_CLICK := preload("res://assets/Tilesets/Mouse/click_mouse.png")

@onready var jugar_button: Button = $CenterContainer/VBoxContainer/Jugar
@onready var opciones_button: Button = $CenterContainer/VBoxContainer/Opciones
@onready var salir_button: Button = $CenterContainer/VBoxContainer/Salir

func _ready():
	# Configuración inicial del mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	
	# Conexión de señales de botones
	jugar_button.pressed.connect(_on_jugar_pressed)
	opciones_button.pressed.connect(_on_opciones_pressed)
	salir_button.pressed.connect(_on_salir_pressed)
	
	# Conexión de señales de hover (mejor que conectar a todo el Control)
	for button in [jugar_button, opciones_button, salir_button]:
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
		button.button_down.connect(_on_button_pressed.bind(button))
		button.button_up.connect(_on_button_released.bind(button))

func _on_button_hovered(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_HOVER)
	button.scale = Vector2(1.05, 1.05)  # Efecto visual adicional

func _on_button_unhovered(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	button.scale = Vector2(1.0, 1.0)

func _on_button_pressed(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_CLICK)
	button.scale = Vector2(0.95, 0.95)  # Efecto de pulsación

func _on_button_released(button: Button):
	Input.set_custom_mouse_cursor(CURSOR_HOVER)
	button.scale = Vector2(1.05, 1.05)

func _on_jugar_pressed():
	# Transición suave antes de cambiar de escena
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_opciones_pressed():
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")

func _on_salir_pressed():
	get_tree().quit()
