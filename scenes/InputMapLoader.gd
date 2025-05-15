class_name InputMapLoader

static func load_scheme(scheme: int):
	# Limpiar acciones existentes
	for action in InputMap.get_actions():
		InputMap.action_erase_events(action)
	
	# Configurar acciones según el esquema
	match scheme:
		0:  # Teclado WASD
			_setup_key(KEY_A, "left")
			_setup_key(KEY_D, "right")
			_setup_key(KEY_W, "up")
			_setup_key(KEY_S, "down")
			_setup_key(KEY_E, "grab")
			_setup_key(KEY_ESCAPE, "esc")
			
		1:  # Teclado Flechas
			_setup_key(KEY_LEFT, "left")
			_setup_key(KEY_RIGHT, "right")
			_setup_key(KEY_UP, "up")
			_setup_key(KEY_DOWN, "down")
			_setup_key(KEY_SPACE, "grab")
			_setup_key(KEY_ESCAPE, "esc")
			
		2:  # Mando
			# Eje izquierdo para movimiento
			_setup_joy_axis(JOY_AXIS_LEFT_X, -1.0, "left")
			_setup_joy_axis(JOY_AXIS_LEFT_X, 1.0, "right")
			_setup_joy_axis(JOY_AXIS_LEFT_Y, -1.0, "up")
			_setup_joy_axis(JOY_AXIS_LEFT_Y, 1.0, "down")
			# Botones
			_setup_joy_button(JOY_BUTTON_A, "grab")
			_setup_joy_button(JOY_BUTTON_START, "esc")

static func _setup_key(keycode: int, action: String):
	var event = InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action, event)

static func _setup_joy_button(button: int, action: String):
	var event = InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

static func _setup_joy_axis(axis: int, axis_value: float, action: String):
	var event = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)
