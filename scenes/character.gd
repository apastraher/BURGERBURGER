extends CharacterBody2D
class_name Jugador

const SPEED = 100.0
var dinero: int = 0
var ingrediente_actual = null
var caja_cercana = null
var encimera_cercana = null
var sarten_cercana = null
var papelera_cercana = null
var cliente_cercano: Cliente = null

@onready var label_dinero = get_node("../Dinero/MoneyLabel")
@onready var hand_sprite = $ManoSprite
@onready var body_sprite = $Sprite2D
@onready var pickup_sound = $PickupSound

func _ready():
	hand_sprite.visible = false
	add_to_group("jugador")

func _physics_process(delta):
	manejar_movimiento()
	manejar_animacion()
	
	if Input.is_action_just_pressed("grab"):
		manejar_interaccion()
	
	move_and_slide()

func manejar_movimiento():
	var direccion = Input.get_vector("left", "right", "up", "down")
	velocity = direccion * SPEED if direccion != Vector2.ZERO else Vector2.ZERO

func manejar_animacion():
	var caminando = velocity != Vector2.ZERO
	var agarrando = ingrediente_actual != null
	
	if caminando:
		body_sprite.play("walk_grab" if agarrando else "walk")
	else:
		body_sprite.play("grab" if agarrando else "idle")
	
	body_sprite.flip_h = velocity.x < 0

func manejar_interaccion():
	if not ingrediente_actual:
		if cliente_cercano and cliente_cercano.estado_actual == Cliente.Estado.LISTO_PARA_PEDIR:
			cliente_cercano.interactuar(self)
		elif caja_cercana:
			tomar_de_caja()
		elif encimera_cercana and encimera_cercana.tiene_objetos():
			recoger_de_encimera()
		elif sarten_cercana:
			sarten_cercana.interactuar_con_jugador(self)
	else:
		if cliente_cercano and typeof(ingrediente_actual) == TYPE_DICTIONARY and ingrediente_actual["tipo"] == "plato":
			cliente_cercano.interactuar(self)
		elif encimera_cercana:
			soltar_ingrediente()
		elif papelera_cercana:
			limpiar_manos()
		elif sarten_cercana:
			sarten_cercana.interactuar_con_jugador(self)

func recibir_recompensa(cantidad: int):
	dinero += cantidad
	label_dinero.text = str(dinero)
	print("Dinero recibido: ", cantidad, " | Total: ", dinero)

func tiene_pedido_correcto(pedido_cliente: Array) -> bool:
	if not ingrediente_actual or typeof(ingrediente_actual) != TYPE_DICTIONARY:
		return false
	if ingrediente_actual["tipo"] != "plato":
		return false
	
	var ingredientes_plato = ingrediente_actual["ingredientes"]
	if ingredientes_plato.size() != pedido_cliente.size():
		return false
	
	for i in range(ingredientes_plato.size()):
		if ingredientes_plato[i] != pedido_cliente[i]:
			return false
	
	return true

func tomar_de_caja():
	if not caja_cercana or not caja_cercana.has_method("recoger_ingrediente"):
		return
	
	var nuevo_ingrediente = caja_cercana.recoger_ingrediente()
	if not nuevo_ingrediente:
		return
	
	ingrediente_actual = nuevo_ingrediente
	var path = "res://assets/ingredientes/%s.png" % nuevo_ingrediente
	if ResourceLoader.exists(path):
		hand_sprite.texture = load(path)
		hand_sprite.visible = true
		hand_sprite.scale = Vector2(0.7, 0.7)
		pickup_sound.play()

func recoger_de_encimera():
	if not encimera_cercana:
		return
	
	var obj = encimera_cercana.recoger_objeto(global_position)
	if obj.is_empty():
		return
	
	ingrediente_actual = obj  # Asignamos el objeto recogido (diccionario) directamente a ingrediente_actual
	mostrar_ingredientes_en_mano(obj)  # Mostrar los ingredientes si es un plato
	pickup_sound.play()


func mostrar_ingredientes_en_mano(data: Dictionary):
	hand_sprite.visible = false
	for child in hand_sprite.get_children():
		child.queue_free()

	if data["tipo"] == "plato":
		hand_sprite.texture = load("res://assets/ingredientes/plato.png")
		hand_sprite.scale = Vector2(0.7, 0.7)
		hand_sprite.visible = true
		
		var offset_apilado = 8
		for i in range(data["ingredientes"].size()):
			var nombre = data["ingredientes"][i]
			var path = "res://assets/ingredientes/%s.png" % nombre
			if ResourceLoader.exists(path):
				var sprite = Sprite2D.new()
				sprite.texture = load(path)
				sprite.scale = Vector2(0.7, 0.7)
				sprite.position = Vector2(0, -i * offset_apilado)
				sprite.z_index = 10 + i
				hand_sprite.add_child(sprite)
	else:
		var path = "res://assets/ingredientes/%s.png" % data["tipo"]
		if ResourceLoader.exists(path):
			hand_sprite.texture = load(path)
			hand_sprite.scale = Vector2(0.7, 0.7)
			hand_sprite.visible = true

# Dentro de la función `soltar_ingrediente()`

func soltar_ingrediente():
	if not ingrediente_actual or not encimera_cercana:
		return
	
	var exito = false
	
	# Verificamos si el ingrediente actual es un string (ingrediente simple)
	if typeof(ingrediente_actual) == TYPE_STRING:
		exito = encimera_cercana.colocar_objeto(
			ingrediente_actual,
			global_position,
			hand_sprite.texture
		)
	
	# Si es un diccionario y contiene un plato, lo colocamos
	elif typeof(ingrediente_actual) == TYPE_DICTIONARY and ingrediente_actual.has("tipo"):
		if ingrediente_actual["tipo"] == "plato":
			exito = encimera_cercana.colocar_plato(
				global_position,
				hand_sprite.texture,
				ingrediente_actual["ingredientes"]
			)
		else:
			# Si es un ingrediente (no plato), colocamos el ingrediente
			exito = encimera_cercana.colocar_objeto(
				ingrediente_actual["tipo"],  # El tipo es el nombre del ingrediente
				global_position,
				hand_sprite.texture
			)
	
	if exito:
		limpiar_manos()
		print("Ingrediente colocado en la mesa.")



func limpiar_manos():
	ingrediente_actual = null
	hand_sprite.texture = null
	hand_sprite.visible = false
	for child in hand_sprite.get_children():
		child.queue_free()

func recibir_ingrediente(tipo_ingrediente: String):
	ingrediente_actual = tipo_ingrediente
	var path = "res://assets/ingredientes/%s.png" % tipo_ingrediente
	if ResourceLoader.exists(path):
		hand_sprite.texture = load(path)
		hand_sprite.scale = Vector2(0.7, 0.7)
		hand_sprite.visible = true
		pickup_sound.play()

func _on_area_2d_area_entered(area: Area2D):
	if area.is_in_group("cajas"):
		caja_cercana = area
	elif area.is_in_group("encimeras"):
		encimera_cercana = area.get_parent()
	elif area.is_in_group("clientes"):
		cliente_cercano = area.get_parent()
	elif area.is_in_group("papeleras"):
		papelera_cercana = area
	elif area.is_in_group("sartenes"):
		sarten_cercana = area.get_parent()

func _on_area_2d_area_exited(area: Area2D):
	if area == caja_cercana:
		caja_cercana = null
	elif area.is_in_group("encimeras"):
		encimera_cercana = null
	elif area.is_in_group("clientes"):
		cliente_cercano = null
	elif area.is_in_group("papeleras"):
		papelera_cercana = null
	elif area.is_in_group("sartenes"):
		sarten_cercana = null
