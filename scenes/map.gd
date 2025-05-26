extends Node2D

@export var umbral_dinero: int = 800
@onready var timer_node = $TimerNode
@onready var nodo_dinero = $Dinero
@onready var tutorial_scene = preload("res://scenes/tutorial.tscn")

# Añadido: carga de música ambiente (opcional si ya está asignada en el nodo)
@onready var musica_ambiente: AudioStreamPlayer2D = $MusicaAmbiente

func _ready() -> void:
	# Reproducir música ambiente al empezar
	if not musica_ambiente.playing:
		musica_ambiente.play()

	# Verificar si debemos mostrar el tutorial
	var fade = get_node_or_null("/root/Fade")
	var config = ConfigFile.new()
	if config.load("user://config.cfg") == OK:
		var should_run_tutorial = config.get_value("tutorial", "should_run", false)
		config.set_value("tutorial", "should_run", false)
		config.save("user://config.cfg")
		
		if should_run_tutorial:
			_iniciar_tutorial()

	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

	fade.reset_color_rect()
	if timer_node and not timer_node.tiempo_finalizado.is_connected(_on_timer_node_tiempo_finalizado):
		timer_node.tiempo_finalizado.connect(_on_timer_node_tiempo_finalizado)

func _iniciar_tutorial():
	var tutorial = tutorial_scene.instantiate()
	add_child(tutorial)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_timer_node_tiempo_finalizado() -> void:
	get_tree().paused = false
	
	if Fade:
		Fade.reset_color_rect()
		Fade.fade_completed.connect(_cambiar_escena, CONNECT_ONE_SHOT)
		await Fade.fade_in(1.0)
	else:
		print("Advertencia: Nodo Fade no encontrado")
		_cambiar_escena()

func _cambiar_escena() -> void:
	var dinero_actual = int(nodo_dinero.get_node("MoneyLabel").text)
	var escena_path = "res://scenes/final_bueno.tscn" if dinero_actual >= umbral_dinero else "res://scenes/final_malo.tscn"

	if ResourceLoader.exists(escena_path):
		get_tree().change_scene_to_file(escena_path)
