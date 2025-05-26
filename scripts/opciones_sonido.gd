extends Control

@onready var master_slider = $CanvasLayer/VBoxContainer/HBoxContainer/SliderMaestro
@onready var music_slider = $CanvasLayer/VBoxContainer/HBoxContainer2/SliderMusica
@onready var sfx_slider = $CanvasLayer/VBoxContainer/HBoxContainer3/SliderSFX
@onready var master_value = $CanvasLayer/VBoxContainer/HBoxContainer/MasterValue
@onready var music_value = $CanvasLayer/VBoxContainer/HBoxContainer2/MusicValue
@onready var sfx_value = $CanvasLayer/VBoxContainer/HBoxContainer3/SFXValue
@onready var prueba_efecto: AudioStreamPlayer2D = $PruebaEfecto

var previous_sfx_value := 0

func _ready():
	# Cargar valores
	master_slider.value = Settings.load_volume("Master")
	music_slider.value = Settings.load_volume("Music")
	sfx_slider.value = Settings.load_volume("SFX")
	
	# Guardar valor inicial de SFX
	previous_sfx_value = sfx_slider.value
	
	# Aplicar volúmenes
	apply_volume("Master", master_slider.value)
	apply_volume("Music", music_slider.value)
	apply_volume("SFX", sfx_slider.value)
	
	update_volume_labels()
	
	# Conectar señales
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	
	master_slider.grab_focus()


func apply_volume(bus_name: String, value: float):
	var db_volume = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	Settings.save_volume(bus_name, value)

func update_volume_labels():
	master_value.text = "%d%%" % master_slider.value
	music_value.text = "%d%%" % music_slider.value
	sfx_value.text = "%d%%" % sfx_slider.value

func _on_master_slider_value_changed(value: float):
	apply_volume("Master", value)
	master_value.text = "%d%%" % value

func _on_music_slider_value_changed(value: float):
	apply_volume("Music", value)
	music_value.text = "%d%%" % value

func _on_sfx_slider_value_changed(value: float):
	apply_volume("SFX", value)
	sfx_value.text = "%d%%" % value

	var previous_10 = int(previous_sfx_value / 10)
	var current_10 = int(value / 10)

	# Si cambió de "decena" hacia arriba o hacia abajo, suena el sonido
	if current_10 != previous_10:
		prueba_efecto.play()

	previous_sfx_value = value

func _on_atras_sonido_pressed() -> void:
	# No necesitamos guardar aquí porque ya se guarda en cada cambio
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")
