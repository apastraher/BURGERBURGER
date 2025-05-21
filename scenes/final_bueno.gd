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
		fade.color_rect.modulate = Color(0, 0, 0, 1)
		fade.color_rect.show()
		await fade.fade_out(0.5)
	else:
		printerr("Advertencia: Nodo Fade no encontrado")

func _on_salir_pressed() -> void:
	# Evitar múltiples ejecuciones
	if exiting:
		return
	
	exiting = true
	
	# 1. Ejecutar animación de fade (si existe)
	if is_instance_valid(fade):
		await fade.fade_in(0.5)
	
	# 2. Cargar el menú principal de forma segura
	var menu_path = "res://scenes/menu.tscn"
	
	# Verificar existencia del recurso
	if not ResourceLoader.exists(menu_path):
		printerr("Error: No se encontró la escena del menú en ", menu_path)
		get_tree().quit()
		return
	
	# 3. Cambiar a la escena del menú
	var menu = load(menu_path)
	get_tree().change_scene_to_packed(menu)
	
	# 4. Limpieza final
	queue_free()

# Manejo seguro al cerrar
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(fade):
			fade.queue_free()
