extends Node2D

@export var umbral_dinero: int = 0
@onready var timer_node = $TimerNode
@onready var nodo_dinero = $Dinero
@onready var tutorial_scene = preload("res://scenes/tutorial.tscn")

func _ready() -> void:
	# Verificar si debemos mostrar el tutorial
	var config = ConfigFile.new()
	if config.load("user://config.cfg") == OK:
		var should_run_tutorial = config.get_value("tutorial", "should_run", false)
		config.set_value("tutorial", "should_run", false)  # Resetear
		config.save("user://config.cfg")
		
		if should_run_tutorial:
			_iniciar_tutorial()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
	if timer_node:
		timer_node.tiempo_finalizado.connect(_on_timer_finalizado)

func _iniciar_tutorial():
	var tutorial = tutorial_scene.instantiate()
	add_child(tutorial)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_timer_finalizado() -> void:
	get_tree().paused = false
	
	# Manejar transición de escena
	var fade = get_node("/root/Fade")
	if fade:
		fade.fade_completed.connect(_cambiar_escena, CONNECT_ONE_SHOT)
		fade.fade_in(1.0)
	else:
		_cambiar_escena()

func _cambiar_escena() -> void:
	var dinero_actual = int(nodo_dinero.get_node("MoneyLabel").text)
	var escena_path = "res://scenes/final_bueno.tscn" if dinero_actual >= umbral_dinero else "res://scenes/final_malo.tscn"
	
	if ResourceLoader.exists(escena_path):
		get_tree().change_scene_to_file(escena_path)
