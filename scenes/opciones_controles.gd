extends Control

@onready var scheme_image = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/TextureRect
@onready var scheme_label = $CanvasLayer/Panel/VBoxContainer/LabelDescripcion
@onready var anterior_button = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/Anterior
@onready var posterior_button = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/Posterior
@onready var atras_button = $CanvasLayer/Panel/VBoxContainer/AtrasControles

# Texturas para cada esquema y tipo de mando
var scheme_textures = {
	0: {  # Teclado WASD
		"keyboard": preload("res://assets/Tilesets/UI/Controles/keyboard_wasd.png"),
	},
	1: {  # Teclado Flechas
		"keyboard": preload("res://assets/Tilesets/UI/Controles/keyboard_arrows.png"),
	},
	2: {  # Mando
		"xbox": preload("res://assets/Tilesets/UI/Controles/gamepad_xbox.png"),
		"playstation": preload("res://assets/Tilesets/UI/Controles/gamepad_generic.png"),
		"generic": preload("res://assets/Tilesets/UI/Controles/gamepad_generic.png")
	}
}

var scheme_descriptions = {
	0: "CLÁSICO: Movimiento con AWSD, interactuar con E",
	1: "SENCILLO: Movimiento con Flechas, interactuar con Espacio",
	2: {
		"xbox": "MANDO (Xbox): Movimiento con Joystick, interactuar con A",
		"playstation": "MANDO (PlayStation): Movimiento con Joystick, interactuar con X",
		"generic": "MANDO: Conecta un mando para usar este esquema"
	}
}

var current_scheme = 0
var base_image_sizes = {
	0: Vector2(200, 200),  # WASD (ancho, alto)
	1: Vector2(200, 200),  # Flechas
	2: Vector2(200, 200)   # Mando
}

func _ready():
	# Configuración inicial
	configure_ui_layout()
	update_display()
	anterior_button.grab_focus()
	
	# Conectar señal de cambio de mando
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device_id, connected):
	# Actualizar solo si estamos en modo mando
	if current_scheme == 2:
		update_display()

func configure_ui_layout():
	# Configuración básica del TextureRect
	scheme_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scheme_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	scheme_image.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scheme_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Configurar botones
	anterior_button.custom_minimum_size = Vector2(80, 80)
	posterior_button.custom_minimum_size = Vector2(80, 80)
	if atras_button:
		atras_button.custom_minimum_size = Vector2(150, 50)

func get_controller_type() -> String:
	var devices = Input.get_connected_joypads()
	if devices.size() > 0:
		var name = Input.get_joy_name(devices[0]).to_lower()
		if "playstation" in name or "dualshock" in name or "dual sense" in name:
			return "playstation"
		elif "xbox" in name or "x-box" in name:
			return "xbox"
	return "generic"

func update_display():
	# Determinar el tipo de controlador
	var controller_type = "keyboard"
	var mando_conectado = Input.get_connected_joypads().size() > 0
	
	if current_scheme == 2:
		controller_type = get_controller_type()
		
		# Actualizar estado del botón Atrás
		if atras_button:
			atras_button.disabled = not mando_conectado
	
	# Actualizar imagen
	var texture_dict = scheme_textures.get(current_scheme, {})
	var selected_texture = texture_dict.get(controller_type, texture_dict.get("generic", null))
	
	if selected_texture:
		scheme_image.texture = selected_texture
		reset_image_size()
	
	# Actualizar descripción con estado de conexión
	if current_scheme == 2:
		if controller_type == "generic":
			scheme_label.text = scheme_descriptions[2]["generic"]
			if not mando_conectado:
				scheme_label.text += "\n[No se detectó ningún mando conectado]"
		else:
			scheme_label.text = scheme_descriptions[2].get(controller_type, "")
	else:
		scheme_label.text = scheme_descriptions[current_scheme]
		# Habilitar botón Atrás si no es modo mando
		if atras_button:
			atras_button.disabled = false
	
	# Cargar el esquema real de controles
	InputMapLoader.load_scheme(current_scheme)
	Settings.set_control_scheme(current_scheme)

func reset_image_size():
	# Restablecer al tamaño base para el esquema actual
	var base_size = base_image_sizes.get(current_scheme, Vector2(200, 200))
	
	# Ajustar según tamaño de pantalla
	var screen_size = get_viewport_rect().size
	var scale_factor = min(
		screen_size.x * 0.6 / base_size.x,
		screen_size.y * 0.5 / base_size.y
	)
	
	# Aplicar tamaño final
	scheme_image.custom_minimum_size = base_size * scale_factor
	scheme_image.size = base_size * scale_factor

func _on_atras_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")

func _on_anterior_pressed() -> void:
	current_scheme = wrapi(current_scheme - 1, 0, 3)
	update_display()

func _on_posterior_pressed() -> void:
	current_scheme = wrapi(current_scheme + 1, 0, 3)
	update_display()
