extends Control

@onready var master_slider = $CanvasLayer/VBoxContainer/HBoxContainer/SliderMaestro
@onready var music_slider = $CanvasLayer/VBoxContainer/HBoxContainer2/SliderMusica
@onready var sfx_slider = $CanvasLayer/VBoxContainer/HBoxContainer3/SliderSFX
@onready var master_value = $CanvasLayer/VBoxContainer/HBoxContainer/MasterValue
@onready var music_value = $CanvasLayer/VBoxContainer/HBoxContainer2/MusicValue
@onready var sfx_value = $CanvasLayer/VBoxContainer/HBoxContainer3/SFXValue

func _ready():
	# Cargar la configuración de volúmenes desde los ajustes guardados
	master_slider.value = Settings.load_volume("master")
	music_slider.value = Settings.load_volume("music")
	sfx_slider.value = Settings.load_volume("sfx")

	# Actualizar las etiquetas con los valores cargados
	update_volume_labels()

	# Conectar señales para cuando el valor del slider cambie
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

	# Configurar el foco en el slider maestro
	master_slider.grab_focus()



func update_volume_labels():
	master_value.text = "%d%%" % master_slider.value
	music_value.text = "%d%%" % music_slider.value
	sfx_value.text = "%d%%" % sfx_slider.value

func _on_master_slider_value_changed(value: float):
	# Convertir de 0-100 a dB (rango útil: -30dB a 0dB)
	var db_volume = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_volume)
	master_value.text = "%d%%" % value
	Settings.save_volume("master", value / 100.0)  # Guardar como 0-1

func _on_music_slider_value_changed(value: float):
	var db_volume = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db_volume)
	music_value.text = "%d%%" % value
	Settings.save_volume("music", value / 100.0)

func _on_sfx_slider_value_changed(value: float):
	var db_volume = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db_volume)
	sfx_value.text = "%d%%" % value
	Settings.save_volume("sfx", value / 100.0)


func _on_atras_sonido_pressed() -> void:
	# Guardar los valores actuales de los sliders
	Settings.save_volume("master", master_slider.value)
	Settings.save_volume("music", music_slider.value)
	Settings.save_volume("sfx", sfx_slider.value)

	# Cambiar de escena (por ejemplo, a la escena principal o de opciones)
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")
