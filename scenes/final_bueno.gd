extends CanvasLayer

var fade

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	
	fade = get_node_or_null("/root/Fade")
	
	if is_instance_valid(fade):
		fade.color_rect.modulate = Color(0, 0, 0, 1)
		fade.color_rect.show()
		await fade.fade_out(0.5)

func _on_salir_pressed() -> void:
	if is_instance_valid(fade):
		await fade.fade_in(0.5)
	
	var menu_path = "res://scenes/menu.tscn"
	if ResourceLoader.exists(menu_path):
		var menu = load(menu_path)
		get_tree().change_scene_to_packed(menu)
	else:
		push_error("No se encontró la escena del menú")
		get_tree().quit()
