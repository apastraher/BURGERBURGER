extends Node2D
class_name Cliente

enum Estado {ESPERANDO, LISTO_PARA_PEDIR, ESPERANDO_PEDIDO, SATISFECHO, ENOJADO}

@export var velocidad_paciencia: float = 10.0
@export var tiempo_antes_paciencia: float = 2.0
@export var recompensa_base: int = 50
@export var penalizacion: int = 20
@export var tiempo_reaparicion: float = 5.0  # Tiempo entre pedidos

var estado_actual: Estado = Estado.ESPERANDO
var pedido: Array = []
var paciencia_actual: float = 100.0

@onready var bubble: TextureRect = $PedidoBocadillo
@onready var hbox: VBoxContainer = $PedidoBocadillo/VBoxIngredientes
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer_paciencia: Timer = $TimerPaciencia
@onready var sprite_exclamacion: Sprite2D = $PedidoBocadillo/Exclamacion

var ingredientes_texturas = {
	"pan": preload("res://assets/ingredientes/pan.png"),
	"carne_cocinada": preload("res://assets/ingredientes/carne_cocinada.png"),
	"queso": preload("res://assets/ingredientes/queso.png")
}

signal cliente_satisfecho
signal cliente_enfadado

func _ready():
	resetear_cliente()
	iniciar_primer_pedido()

func resetear_cliente():
	# Restablece todos los valores al estado inicial
	estado_actual = Estado.ESPERANDO
	paciencia_actual = 100.0
	bubble.visible = false
	progress_bar.visible = false
	progress_bar.value = paciencia_actual
	sprite_exclamacion.visible = false
	
	# Limpiar cualquier ingrediente mostrado
	for child in hbox.get_children():
		child.queue_free()

func iniciar_primer_pedido():
	await get_tree().create_timer(5).timeout
	mostrar_disponible_para_pedir()

func mostrar_disponible_para_pedir():
	if estado_actual != Estado.ESPERANDO:
		return
		
	estado_actual = Estado.LISTO_PARA_PEDIR
	bubble.visible = true
	sprite_exclamacion.visible = true

func interactuar(jugador: CharacterBody2D):
	match estado_actual:
		Estado.LISTO_PARA_PEDIR:
			empezar_pedido()
		Estado.ESPERANDO_PEDIDO:
			verificar_entrega(jugador)

func empezar_pedido():
	sprite_exclamacion.visible = false
	estado_actual = Estado.ESPERANDO_PEDIDO
	bubble.visible = true
	generar_pedido()
	mostrar_pedido()
	
	await get_tree().create_timer(tiempo_antes_paciencia).timeout
	progress_bar.visible = true
	timer_paciencia.start()

func generar_pedido():
	var ingredientes = ["carne_cocinada", "queso"]
	var num_ingredientes = randi_range(1, 2)
	var seleccionados = []
	var ingredientes_disponibles = ingredientes.duplicate()

	for i in range(num_ingredientes):
		if ingredientes_disponibles.is_empty():
			break
		var idx = randi() % ingredientes_disponibles.size()
		seleccionados.append(ingredientes_disponibles[idx])
		ingredientes_disponibles.remove_at(idx)

	pedido = ["pan"] + seleccionados + ["pan"]

func verificar_entrega(jugador: CharacterBody2D):
	var entregado = jugador.ingrediente_actual
	if entregado and typeof(entregado) == TYPE_DICTIONARY and entregado.has("ingredientes"):
		var correctos = contar_ingredientes_correctos(entregado["ingredientes"])
		var proporcion = float(correctos) / pedido.size()
		var recompensa = int(recompensa_base * proporcion)
		jugador.recibir_recompensa(recompensa)

		if correctos == pedido.size():
			finalizar_interaccion(Estado.SATISFECHO)
		else:
			finalizar_interaccion(Estado.ENOJADO)
		
		jugador.limpiar_manos()

func finalizar_interaccion(estado_final: Estado):
	estado_actual = estado_final
	timer_paciencia.stop()
	
	if estado_final == Estado.SATISFECHO:
		cliente_satisfecho.emit()
	else:
		cliente_enfadado.emit()
	
	# Ocultar cliente temporalmente
	bubble.visible = false
	progress_bar.visible = false
	
	# Programar reaparición
	await get_tree().create_timer(tiempo_reaparicion).timeout
	resetear_cliente()
	mostrar_disponible_para_pedir()

func contar_ingredientes_correctos(entregados: Array) -> int:
	var correctos = 0
	for i in range(min(entregados.size(), pedido.size())):
		if entregados[i] == pedido[i]:
			correctos += 1
	return correctos

func _perder_paciencia():
	paciencia_actual = max(paciencia_actual - velocidad_paciencia, 0)
	progress_bar.value = paciencia_actual

	if paciencia_actual < 30.0:
		progress_bar.add_theme_color_override("font_color", Color.RED)

	if paciencia_actual <= 0:
		finalizar_interaccion(Estado.ENOJADO)
		
func mostrar_pedido():
	# Limpiar ingredientes anteriores
	for child in hbox.get_children():
		child.queue_free()
	
	# Configurar el contenedor para disposición vertical
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Mostrar cada ingrediente del pedido
	for ingr in pedido:
		var tex = TextureRect.new()
		if ingredientes_texturas.has(ingr):
			tex.texture = ingredientes_texturas[ingr]
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.custom_minimum_size = Vector2(16, 16)  # Tamaño más pequeño
			tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			# Añadir espacio entre ingredientes
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 4)  # Espacio vertical de 4px
			
			hbox.add_child(tex)
			hbox.add_child(spacer)
	
	# Eliminar el último spacer si existe
	if hbox.get_child_count() > 0 and hbox.get_child(hbox.get_child_count() - 1) is Control:
		hbox.get_child(hbox.get_child_count() - 1).queue_free()
	
	hbox.queue_redraw()
