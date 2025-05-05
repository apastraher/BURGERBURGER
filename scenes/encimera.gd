extends Node2D
class_name Encimera

# Variables de estado
var objetos_colocados = {}  # {posición: {tipo: String, sprite: Sprite2D, ingredientes: Array}}
var posiciones = []  # Vector2 de posiciones de colocación

# Configuración
@export var offset_apilado: float = 5.0
@export var radio_interaccion: float = 100.0
@export var scale_item: float = 0.7  # Ajusta este valor según necesites

func _ready():
	# Pre-cargamos las posiciones de colocación
	for i in range(1, 7):
		var marker = get_node_or_null("PosicionColocacion" + str(i))
		if marker:
			posiciones.append(marker.global_position)

func colocar_objeto(nombre_ingrediente: String, player_pos: Vector2, textura_ingrediente: Texture2D) -> bool:
	var pos_idx = _encontrar_posicion_mas_cercana(player_pos)
	if pos_idx == -1:
		return false
	
	# Si hay un plato en esa posición, emplatar
	if objetos_colocados.has(pos_idx) and objetos_colocados[pos_idx]["tipo"] == "plato":
		if nombre_ingrediente != "plato":
			return _emplatar_ingrediente(nombre_ingrediente, textura_ingrediente, pos_idx)
	# Si está vacío, colocar normal
	elif not objetos_colocados.has(pos_idx):
		return _colocar_en_posicion(nombre_ingrediente, textura_ingrediente, pos_idx)
	
	return false

func _encontrar_posicion_mas_cercana(player_pos: Vector2) -> int:
	var pos_mas_cercana = -1
	var distancia_minima = INF
	
	for i in range(posiciones.size()):
		var distancia = player_pos.distance_to(posiciones[i])
		if distancia < radio_interaccion and distancia < distancia_minima:
			distancia_minima = distancia
			pos_mas_cercana = i
	
	return pos_mas_cercana

func _colocar_en_posicion(nombre_ingrediente: String, textura_ingrediente: Texture2D, pos_idx: int) -> bool:
	var sprite = Sprite2D.new()
	sprite.texture = textura_ingrediente
	sprite.scale = Vector2(scale_item, scale_item)  # Usa la escala global
	sprite.z_index = 10
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # Para pixel art

	add_child(sprite)
	sprite.global_position = posiciones[pos_idx]
	
	objetos_colocados[pos_idx] = {
		"tipo": nombre_ingrediente,
		"sprite": sprite,
		"ingredientes": []
	}
	return true

func _emplatar_ingrediente(nombre_ingrediente: String, textura_ingrediente: Texture2D, pos_idx: int) -> bool:
	var plato = objetos_colocados[pos_idx]
	var nuevo_sprite = Sprite2D.new()
	nuevo_sprite.texture = textura_ingrediente
	nuevo_sprite.scale = Vector2(scale_item, scale_item)  # Misma escala global
	nuevo_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var altura = plato["ingredientes"].size()
	nuevo_sprite.position = Vector2(0, -altura * offset_apilado * scale_item)  # Ajusta offset con escala
	nuevo_sprite.z_index = plato["sprite"].z_index + altura + 1
	
	plato["sprite"].add_child(nuevo_sprite)
	
	objetos_colocados[pos_idx]["ingredientes"].append({
		"sprite": nuevo_sprite,
		"tipo": nombre_ingrediente
	})

	# Animación con escala correcta
	var tween = create_tween()
	tween.tween_property(nuevo_sprite, "scale", Vector2(scale_item, scale_item), 0.2).from(Vector2(scale_item*0.7, scale_item*0.7))
	return true

func colocar_plato(player_pos: Vector2, textura_plato: Texture2D, ingredientes: Array = []) -> bool:
	var pos_idx = _encontrar_posicion_mas_cercana(player_pos)
	if pos_idx == -1 or objetos_colocados.has(pos_idx):
		return false

	# Crear el sprite del plato
	var sprite_plato = Sprite2D.new()
	sprite_plato.texture = textura_plato
	sprite_plato.scale = Vector2(scale_item, scale_item)  # Escala global
	sprite_plato.z_index = 5
	sprite_plato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite_plato)
	sprite_plato.global_position = posiciones[pos_idx]
	
	# Configurar el objeto plato
	objetos_colocados[pos_idx] = {
		"tipo": "plato",
		"sprite": sprite_plato,
		"ingredientes": []
	}
	
	# Colocar ingredientes con la misma escala
	for i in range(ingredientes.size()):
		var ingrediente_data = ingredientes[i]
		var ingrediente_sprite = Sprite2D.new()
		ingrediente_sprite.texture = load("res://assets/ingredientes/%s.png" % ingrediente_data)
		ingrediente_sprite.scale = Vector2(scale_item, scale_item)
		ingrediente_sprite.position = Vector2(0, -i * offset_apilado * scale_item)
		ingrediente_sprite.z_index = 6 + i
		ingrediente_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite_plato.add_child(ingrediente_sprite)
		
		objetos_colocados[pos_idx]["ingredientes"].append({
			"sprite": ingrediente_sprite,
			"tipo": ingrediente_data
		})
	
	return true

func recoger_objeto(player_pos: Vector2) -> Dictionary:
	var pos_idx = _encontrar_posicion_mas_cercana(player_pos)
	if pos_idx == -1 or not objetos_colocados.has(pos_idx):
		return {}
	
	var objeto = objetos_colocados[pos_idx]
	var resultado = {
		"tipo": objeto["tipo"],
		"ingredientes": []
	}

	# Eliminar sprites
	objeto["sprite"].queue_free()
	for ingrediente in objeto["ingredientes"]:
		resultado["ingredientes"].append(ingrediente["tipo"])
		ingrediente["sprite"].queue_free()
	
	objetos_colocados.erase(pos_idx)
	return resultado

func tiene_objetos() -> bool:
	return not objetos_colocados.is_empty()
