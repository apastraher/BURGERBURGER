extends Node

# Volúmenes normalizados (0.0 a 1.0)
var volumes := {
	"master": 1.0,
	"music": 1.0,
	"sfx": 1.0
}

# Esquema de control
var control_scheme: int = 0  # 0=AWSD, 1=Flechas, 2=Mando

const SAVE_PATH = "user://settings.cfg"

func _ready():
	load_settings()

func load_volume(bus_name: String) -> float:
	return (volumes.get(bus_name, 1.0)) * 100

func save_volume(bus_name: String, value: float):
	var normalized_value = value / 100.0
	volumes[bus_name] = normalized_value
	_apply_volume(bus_name, normalized_value)
	save_settings()

func _apply_volume(bus_name: String, value: float):
	var index = AudioServer.get_bus_index(bus_name.capitalize())
	if index != -1:
		AudioServer.set_bus_volume_db(index, linear_to_db(value))

func save_settings():
	var config = ConfigFile.new()

	# Guardar volúmenes
	for name in volumes.keys():
		config.set_value("audio", name + "_volume", volumes[name])

	# Guardar controles
	config.set_value("controls", "control_scheme", control_scheme)

	config.save(SAVE_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err == OK:
		for name in volumes.keys():
			var key = name + "_volume"
			volumes[name] = config.get_value("audio", key, 1.0)
			_apply_volume(name, volumes[name])

		control_scheme = config.get_value("controls", "control_scheme", 0)
	else:
		save_settings()

func set_control_scheme(scheme: int):
	control_scheme = scheme
	InputMapLoader.load_scheme(scheme)
