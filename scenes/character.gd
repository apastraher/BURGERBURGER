extends CharacterBody2D

const SPEED = 100.0
var ingrediente_actual = null
var caja_cercana = null
var encimera_cercana = null
var sarten_cercana = null
var papelera_cercana = null

@onready var hand_sprite = $ManoSprite
@onready var body_sprite = $Sprite2D
@onready var pickup_sound = $PickupSound
@onready var throw_sound = $ThrowSound

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
		if caja_cercana:
			tomar_de_caja()
		elif encimera_cercana and encimera_cercana.tiene_objetos():
			recoger_de_encimera()
		elif sarten_cercana:
			sarten_cercana.interactuar_con_jugador(self)
	else:
		if encimera_cercana:
			soltar_ingrediente()
		elif papelera_cercana:
			limpiar_manos()
		elif sarten_cercana:
			sarten_cercana.interactuar_con_jugador(self)

# Métodos de interacción con objetos
func tomar_de_caja():
	if not caja_cercana.has_method("recoger_ingrediente"):
		return
	
	ingrediente_actual = caja_cercana.recoger_ingrediente()
	if not ingrediente_actual:
		return
	
	var path = "res://assets/ingredientes/%s.png" % ingrediente_actual
	if ResourceLoader.exists(path):
		hand_sprite.texture = load(path)
		hand_sprite.visible = true
		pickup_sound.play()

func recoger_de_encimera():
	var obj = encimera_cercana.recoger_objeto(global_position)
	if obj.size() == 0:
		return
	
	ingrediente_actual = obj
	mostrar_ingredientes_en_mano(obj)
	pickup_sound.play()

func mostrar_ingredientes_en_mano(data):
	hand_sprite.visible = false
	# Limpiar ingredientes anteriores
	for child in hand_sprite.get_children():
		child.queue_free()

	if data["tipo"] == "plato":
		# Escalar el plato principal correctamente
		hand_sprite.texture = load("res://assets/ingredientes/plato.png")
		hand_sprite.scale = Vector2(0.7, 0.7)  # Escala normal para el plato
		hand_sprite.visible = true
		
		# Añadir ingredientes con offset y escala adecuada
		var offset_apilado = 8  # Aumentamos el offset para mejor visualización
		for i in range(data["ingredientes"].size()):
			var nombre = data["ingredientes"][i]
			var path = "res://assets/ingredientes/%s.png" % nombre
			if ResourceLoader.exists(path):
				var sprite = Sprite2D.new()
				sprite.texture = load(path)
				sprite.scale = Vector2(0.7, 0.7)  # Escala más grande para ingredientes
				sprite.position = Vector2(0, -i * offset_apilado)
				sprite.z_index = 10 + i
				hand_sprite.add_child(sprite)
	else:
		# Para ingredientes individuales
		var path = "res://assets/ingredientes/%s.png" % data["tipo"]
		if ResourceLoader.exists(path):
			hand_sprite.texture = load(path)
			hand_sprite.scale = Vector2(0.5, 0.5)  # Escala normal
			hand_sprite.visible = true

func soltar_ingrediente():
	if not ingrediente_actual or not encimera_cercana:
		return
	
	if typeof(ingrediente_actual) == TYPE_STRING:
		# Ingrediente suelto
		var exito = encimera_cercana.colocar_objeto(
			ingrediente_actual,
			global_position,
			hand_sprite.texture
		)
		if exito:
			limpiar_manos()
	elif typeof(ingrediente_actual) == TYPE_DICTIONARY and ingrediente_actual["tipo"] == "plato":
		# Plato con ingredientes
		var exito = encimera_cercana.colocar_plato(
			global_position,
			hand_sprite.texture,
			ingrediente_actual["ingredientes"]
		)
		if exito:
			limpiar_manos()

func limpiar_manos():
	ingrediente_actual = null
	hand_sprite.texture = null
	hand_sprite.visible = false
	for child in hand_sprite.get_children():
		child.queue_free()

func recibir_ingrediente(tipo_ingrediente: String):
	ingrediente_actual = tipo_ingrediente
	var path = "res://assets/ingredientes/%s.png" % tipo_ingrediente
	hand_sprite.texture = load(path)
	hand_sprite.visible = true
	pickup_sound.play()

# Señales de área
func _on_area_2d_area_entered(area: Area2D):
	if area.is_in_group("cajas"):
		caja_cercana = area
	elif area.is_in_group("encimeras"):
		encimera_cercana = area.get_parent()
	elif area.is_in_group("papeleras"):
		papelera_cercana = area  
	elif area.is_in_group("sartenes"):
		sarten_cercana = area.get_parent()

func _on_area_2d_area_exited(area: Area2D):
	if area == caja_cercana:
		caja_cercana = null
	elif area.is_in_group("encimeras"):
		encimera_cercana = null
	elif area.is_in_group("papeleras"):
		papelera_cercana = null
	elif area.is_in_group("sartenes"):
		sarten_cercana = null
