extends CanvasLayer

func _ready():
	visible = false  # Asegura que el menú esté oculto al inicio
	$CenterContainer/Salir.pressed.connect(_on_salir_pressed)
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
	$CenterContainer/Salir.visible = visible
	
func _on_salir_pressed():
	get_tree().quit()
