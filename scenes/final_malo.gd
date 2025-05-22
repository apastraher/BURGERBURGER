extends CanvasLayer

var fade
var exiting := false  # Bandera para controlar el estado de salida

func _ready() -> void:
	# Configuración inicial segura
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	# Manejo robusto del efecto fade
	fade = get_node_or_null("/root/Fade")
	if is_instance_valid(fade):
		fade.reset_color_rect()
		fade.color_rect.show()
		await fade.fade_out(0.5)
	else:
		printerr("Advertencia: Nodo Fade no encontrado")

func _on_salir_pressed() -> void:
	if exiting:
		return
	exiting = true

	var menu_path = "res://scenes/menu.tscn"
	if not ResourceLoader.exists(menu_path):
		get_tree().quit()
		return

	var menu = load(menu_path)

	get_tree().change_scene_to_packed(menu)
