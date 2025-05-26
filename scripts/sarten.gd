extends Node2D

enum Estado { VACIA, COCINANDO, COCINADA, QUEMADA }
var estado: Estado = Estado.VACIA
var tiempo_transcurrido: float = 0.0
var ingrediente_actual: Sprite2D = null

@export var tiempo_coccion: float = 10.0
@export var tiempo_quemar: float = 20.0

@onready var area_interaccion: Area2D = $Area2D
@onready var timer: Timer = $Timer
@onready var progress_bar_cocinando: ProgressBar = $ProgressBarCocinando
@onready var progress_bar_quemando: ProgressBar = $ProgressBarQuemando

func _ready():
	progress_bar_cocinando.visible = false
	progress_bar_cocinando.max_value = 100
	area_interaccion.body_entered.connect(_on_body_entered)
	area_interaccion.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)
	add_to_group("sartenes")
	z_index = int(global_position.y)

var jugador_cercano: Node2D = null

func _on_body_entered(body: Node2D):
	if body.is_in_group("jugador"):
		jugador_cercano = body

func _on_body_exited(body: Node2D):
	if body == jugador_cercano:
		jugador_cercano = null

func interactuar_con_jugador(jugador: Node2D):
	if not jugador:
		return
	
	match estado:
		Estado.VACIA:
			# Verificación simple y directa
			if typeof(jugador.ingrediente_actual) == TYPE_STRING and jugador.ingrediente_actual == "carne_cruda":
				_empezar_coccion(jugador)
		Estado.COCINADA:
			_dar_ingrediente(jugador)
		Estado.QUEMADA:
			_dar_ingrediente(jugador)

func _empezar_coccion(jugador: Node2D):
	estado = Estado.COCINANDO
	if jugador.has_method("limpiar_manos"):
		jugador.limpiar_manos()
	
	ingrediente_actual = Sprite2D.new()
	ingrediente_actual.texture = preload("res://assets/ingredientes/carne_cruda.png")
	ingrediente_actual.position = Vector2(0, -10)
	ingrediente_actual.z_index = 1
	add_child(ingrediente_actual)
	
	progress_bar_cocinando.visible = true
	progress_bar_cocinando.value = 0
	tiempo_transcurrido = 0.0
	timer.start(1.0)

func _on_timer_timeout():
	tiempo_transcurrido += 1.0
	
	if tiempo_transcurrido < tiempo_coccion:
		progress_bar_cocinando.value = (tiempo_transcurrido / tiempo_coccion) * 100
	else:
		var progreso_quemado = (tiempo_transcurrido - tiempo_coccion) / (tiempo_quemar - tiempo_coccion)
		progress_bar_quemando.value = progreso_quemado * 100
	
	if tiempo_transcurrido >= tiempo_quemar:
		_quemar_carne()
	elif tiempo_transcurrido >= tiempo_coccion and estado == Estado.COCINANDO:
		_terminar_coccion()

		

func _terminar_coccion():
	estado = Estado.COCINADA
	ingrediente_actual.texture = preload("res://assets/ingredientes/carne_cocinada.png")
	
	progress_bar_cocinando.visible = false
	progress_bar_quemando.visible = true
	progress_bar_quemando.value = 0


func _quemar_carne():
	estado = Estado.QUEMADA
	ingrediente_actual.texture = preload("res://assets/ingredientes/carne_quemada.png")
	timer.stop()
	progress_bar_quemando.visible = false


# Cambiado el nombre de _recoger_ingrediente a _dar_ingrediente
func _dar_ingrediente(jugador: Node2D):
	if jugador.has_method("recibir_ingrediente") and jugador.ingrediente_actual == null:
		var tipo_ingrediente = "carne_quemada" if estado == Estado.QUEMADA else "carne_cocinada"
		jugador.recibir_ingrediente(tipo_ingrediente)  # Usando el nuevo nombre
		_resetear_sarten()

func _resetear_sarten():
	if ingrediente_actual:
		ingrediente_actual.queue_free()
		ingrediente_actual = null
	
	estado = Estado.VACIA
	tiempo_transcurrido = 0.0
	progress_bar_cocinando.visible = false
	progress_bar_quemando.visible = false
	timer.stop()
	
	if has_node("Humo"):
		$Humo.emitting = false
