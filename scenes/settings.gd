extends Node

# Volúmenes normalizados (0.0 a 1.0)
var volumes := {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 1.0
}

var control_scheme: int = 0  # 0=AWSD, 1=Flechas, 2=Mando
const SAVE_PATH = "user://settings.cfg"

func _ready():
	load_settings()
	apply_all_volumes()

func apply_all_volumes():
	for bus_name in volumes.keys():
		var index = AudioServer.get_bus_index(bus_name)
		if index != -1:
			AudioServer.set_bus_volume_db(index, linear_to_db(volumes[bus_name]))
		else:
			printerr("Bus de audio no encontrado: ", bus_name)

func load_volume(bus_name: String) -> float:
	return volumes.get(bus_name, 1.0) * 100.0

func save_volume(bus_name: String, value: float):
	var normalized_value = clamp(value, 0.0, 100.0) / 100.0
	volumes[bus_name] = normalized_value
	var index = AudioServer.get_bus_index(bus_name)
	if index != -1:
		AudioServer.set_bus_volume_db(index, linear_to_db(normalized_value))
	save_settings()

func set_control_scheme(scheme: int):
	control_scheme = scheme
	InputMapLoader.load_scheme(scheme)
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	# Guardar volúmenes
	for name in volumes.keys():
		config.set_value("audio", name + "_volume", volumes[name])
	# Guardar controles
	config.set_value("controls", "control_scheme", control_scheme)
	# Guardar archivo
	var err = config.save(SAVE_PATH)
	if err != OK:
		printerr("Error guardando configuración: ", err)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		# Cargar volúmenes
		for name in volumes.keys():
			volumes[name] = config.get_value("audio", name + "_volume", 1.0)
		# Cargar controles
		control_scheme = config.get_value("controls", "control_scheme", 0)
	else:
		# Si no existe el archivo, guardar valores por defecto
		save_settings()
