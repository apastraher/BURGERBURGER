class_name InputMapLoader

static func load_scheme(scheme_index: int):
	# Limpiar acciones previas
	for action in ["move_left", "move_right", "move_up", "move_down", "grab"]:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	
	# Configurar nuevo esquema
	match scheme_index:
		0: # WASD + E
			_create_action("move_left", KEY_A)
			_create_action("move_right", KEY_D)
			_create_action("move_up", KEY_W)
			_create_action("move_down", KEY_S)
			_create_action("grab", KEY_E)
		
		1: # Flechas + Espacio
			_create_action("move_left", KEY_LEFT)
			_create_action("move_right", KEY_RIGHT)
			_create_action("move_up", KEY_UP)
			_create_action("move_down", KEY_DOWN)
			_create_action("grab", KEY_SPACE)
		
		2: # Mando
			_create_joy_action("move_left", JOY_AXIS_LEFT_X, -1.0)
			_create_joy_action("move_right", JOY_AXIS_LEFT_X, 1.0)
			_create_joy_action("move_up", JOY_AXIS_LEFT_Y, -1.0)
			_create_joy_action("move_down", JOY_AXIS_LEFT_Y, 1.0)
			_create_joy_button_action("grab", JOY_BUTTON_A)

static func _create_action(action: String, keycode: int):
	var event = InputEventKey.new()
	event.keycode = keycode
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)

static func _create_joy_action(action: String, axis: int, value: float):
	var event = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)

static func _create_joy_button_action(action: String, button: int):
	var event = InputEventJoypadButton.new()
	event.button_index = button
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)
