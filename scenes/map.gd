extends Node2D

@export var umbral_dinero: int = 0
@onready var timer_node = $TimerNode
@onready var nodo_dinero = $Dinero

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	if not timer_node:
		push_error("TimerNode no encontrado en la escena")
		return
		
	if not nodo_dinero:
		push_error("Nodo Dinero no encontrado en la escena")
		return
		
	if timer_node.has_signal("tiempo_finalizado"):
		timer_node.tiempo_finalizado.connect(_on_timer_finalizado)
	else:
		push_error("La señal 'tiempo_finalizado' no existe en TimerNode")

func _on_timer_finalizado() -> void:
	get_tree().paused = false
	
	# Obtener el nodo Fade (asegúrate de que esté en autoload)
	var fade = get_node("/root/Fade")
	if not fade:
		push_error("Nodo Fade no encontrado")
		_cambiar_escena()
		return
	
	# Conectar la señal solo para esta ocasión
	fade.fade_completed.connect(_cambiar_escena, CONNECT_ONE_SHOT)
	
	# Deshabilitar inputs
	_toggle_pause_menu_input(false)
	
	# Ejecutar fade in (la escena cambiará cuando se complete)
	fade.fade_in(1.0)

func _toggle_pause_menu_input(enable: bool) -> void:
	var pause_menu = get_tree().root.get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.set_process_unhandled_input(enable)

func _cambiar_escena() -> void:
	var money_label = nodo_dinero.get_node("MoneyLabel") as Label
	if not money_label:
		push_error("MoneyLabel no encontrado")
		return
	
	var dinero_actual = int(money_label.text)
	var escena_path = "res://scenes/final_bueno.tscn" if dinero_actual >= umbral_dinero else "res://scenes/final_malo.tscn"
	
	if ResourceLoader.exists(escena_path):
		get_tree().change_scene_to_file(escena_path)
	else:
		push_error("Escena no encontrada: " + escena_path)
		get_tree().quit()
