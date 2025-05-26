extends Control

@export var max_image_width := 200
@export var max_image_height := 200
@export var maintain_aspect_ratio := true

@onready var scheme_image = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/TextureRect
@onready var scheme_label = $CanvasLayer/Panel/VBoxContainer/LabelDescripcion
@onready var anterior_button = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/Anterior
@onready var posterior_button = $CanvasLayer/Panel/VBoxContainer/CenterContainer/HBoxContainer/Posterior
@onready var atras_button = $CanvasLayer/Panel/AtrasControles
@onready var hover_sound = $HoverSoundPlayer

var scheme_textures = {
	0: preload("res://assets/Tilesets/UI/Controles/keyboard_wasd.png"),
	1: preload("res://assets/Tilesets/UI/Controles/keyboard_arrows.png"),
	2: preload("res://assets/Tilesets/UI/Controles/gamepad_generic.png")
}

var scheme_descriptions = [
	"CLÁSICO: Movimiento con AWSD, interactuar con E",
	"SENCILLO: Movimiento con Flechas, interactuar con Espacio",
	"MANDO: Movimiento con Joystick, interactuar con A/X"
]

var current_scheme = 0

func _ready():
	configure_ui_layout()
	current_scheme = Settings.control_scheme
	update_display()
	anterior_button.grab_focus()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	for button in [anterior_button, posterior_button, atras_button]:
		button.mouse_entered.connect(_on_button_hovered)

func _on_joy_connection_changed(device_id, connected):
	update_display()

func configure_ui_layout():
	scheme_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scheme_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if maintain_aspect_ratio else TextureRect.STRETCH_SCALE
	scheme_image.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scheme_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	adjust_image_size()

func adjust_image_size():
	if not scheme_image or not scheme_image.texture:
		return
	var texture = scheme_image.texture
	var texture_size = texture.get_size()
	var scale_factor = 1.0
	if texture_size.x > max_image_width:
		scale_factor = max_image_width / texture_size.x
	if texture_size.y * scale_factor > max_image_height:
		scale_factor = max_image_height / texture_size.y
	var new_size = texture_size * scale_factor
	scheme_image.custom_minimum_size = new_size
	scheme_image.size = new_size

func update_display():
	var mando_conectado = Input.get_connected_joypads().size() > 0
	scheme_image.texture = scheme_textures[current_scheme]
	adjust_image_size()
	scheme_label.text = scheme_descriptions[current_scheme]
	if current_scheme == 2:
		if not mando_conectado:
			scheme_label.text += "\n[Conecta un mando para usar este esquema]"
		else:
			var controller_name = Input.get_joy_name(Input.get_connected_joypads()[0])
			scheme_label.text += "\n[Mando conectado: %s]" % controller_name
	update_buttons_state()
	if current_scheme != 2 or mando_conectado:
		InputMapLoader.load_scheme(current_scheme)

func update_buttons_state():
	var mando_conectado = Input.get_connected_joypads().size() > 0
	if anterior_button:
		anterior_button.modulate.a = 0.7 if current_scheme == 0 else 1.0
	if posterior_button:
		posterior_button.modulate.a = 0.7 if current_scheme == 2 else 1.0
	if atras_button:
		atras_button.disabled = (current_scheme == 2 and not mando_conectado)

func _on_atras_controles_pressed():
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")

func _on_anterior_pressed():
	current_scheme = wrapi(current_scheme - 1, 0, 3)
	Settings.set_control_scheme(current_scheme)
	update_display()

func _on_posterior_pressed():
	current_scheme = wrapi(current_scheme + 1, 0, 3)
	Settings.set_control_scheme(current_scheme)
	update_display()

func _on_button_hovered():
	hover_sound.play()
