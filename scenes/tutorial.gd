extends Control

@onready var fondo_negro: ColorRect = $Fondo
@onready var panel_resaltado: ColorRect = $PanelResaltado
@onready var panel_texto: Panel = $Panel
@onready var texto_explicacion: Label = $Panel/Label

signal tutorial_terminado

var pasos = [
	{"texto": "Bienvenido al tutorial. Aquí aprenderás lo básico.\n\n(Haz clic para continuar)", "pos": Vector2(0, 0), "size": Vector2(0, 0)},
	{"texto": "La jornada empieza a las 12:00 y acaba a las 16:00.\n\n(Haz clic para continuar)", "pos": Vector2(9, 6), "size": Vector2(300, 150)},
	{"texto": "Aquí podrás ver el dinero que vas ganando.\n\n(Haz clic para continuar)", "pos": Vector2(583, 9), "size": Vector2(300, 150)},
	{"texto": "Aquí estás tú, podrás moverte e interactuar con los controles asignados.\n\n(Haz clic para continuar)", "pos": Vector2(335, 166), "size": Vector2(250, 250)},
	{"texto": "Estas cajas contienen los ingredientes, acércate y recógelos cuando los necesites.\n\n(Haz clic para continuar)", "pos": Vector2(600, 350), "size": Vector2(300, 150)},
	{"texto": "Esta es la sartén, puedes cocinar la carne, ten cuidado que no se te queme.\n\n(Haz clic para continuar)", "pos": Vector2(283, 130), "size": Vector2(350, 150)},
	{"texto": "En la mesa podrás dejar los ingredientes o poner los platos para emplatar los pedidos.\n\n(Haz clic para continuar)", "pos": Vector2(324, 130), "size": Vector2(300, 150)},
	{"texto": "En la papelera puedes tirar lo que no vayas a usar. ¡Cuidado con no meterte!\n\n(Haz clic para continuar)", "pos": Vector2(405, 206), "size": Vector2(350, 150)},
	{"texto": "Cuando se te acerque un cliente, acércate a él para atenderle.\n\n(Haz clic para continuar)", "pos": Vector2(423, 175), "size": Vector2(350, 150)},
	{"texto": "Cuando tengas su pedido hecho entrégaselo lo antes posible.\n\n(Haz clic para continuar)", "pos": Vector2(423, 175), "size": Vector2(350, 150)},
	{"texto": "Espero que vaya todo bien, ¡suerte!\n\n(Haz clic para terminar)", "pos": Vector2(0, 0), "size": Vector2(0, 0)}
]

var paso_actual := 0
var timer: Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_avanzar_paso)
	
	_actualizar_paso()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_avanzar_paso()

func _avanzar_paso() -> void:
	timer.stop()
	paso_actual += 1
	if paso_actual >= pasos.size():
		_terminar_tutorial()
	else:
		_actualizar_paso()

func _actualizar_paso() -> void:
	var paso = pasos[paso_actual]
	texto_explicacion.text = paso["texto"]
	panel_resaltado.position = paso["pos"]
	panel_resaltado.size = paso["size"]
	timer.start()

func _terminar_tutorial() -> void:
	# Marcar tutorial como completado
	var config = ConfigFile.new()
	config.load("user://config.cfg")
	config.set_value("tutorial", "completed", true)
	config.save("user://config.cfg")
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/map.tscn")
