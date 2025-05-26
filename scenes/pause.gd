extends CanvasLayer

func _ready():
	visible = false  # Asegura que el menú esté oculto al inicio
	$CenterContainer/VBoxContainer/Salir.pressed.connect(_on_salir_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS  # Para que funcione incluso cuando el juego está en pausa

func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		toggle_pause_menu()
		get_tree().root.set_input_as_handled()  # Evita que el input se propague

func toggle_pause_menu():
	visible = not visible
	get_tree().paused = visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	$ColorRect.visible = visible
	$CenterContainer.visible = visible
	$CenterContainer/VBoxContainer/Salir.visible = visible
	$CenterContainer/VBoxContainer/Volver.visible = visible
	
func _on_salir_pressed():
	get_tree().quit()

func _on_volver_pressed() -> void:
	# Desactivar pausa antes de cambiar de escena
	get_tree().paused = false
	toggle_pause_menu()
	# Cargar el menú principal
	var fade = get_node_or_null("/root/Fade")
	if is_instance_valid(fade):
		await fade.fade_in(0.5)

	get_tree().change_scene_to_file("res://scenes/menu.tscn")
