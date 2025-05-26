extends Area2D
class_name CajaIngrediente

@export var ingrediente: String = "": 
	set(value):
		ingrediente = value

		if is_inside_tree():
			cargar_textura_ingrediente()

@onready var sprite_ingrediente: Sprite2D = $Ingrediente

func _ready():
	cargar_textura_ingrediente()
	z_index = int(global_position.y)

func cargar_textura_ingrediente():
	if ingrediente.is_empty():
		sprite_ingrediente.visible = false
		return

	var paths_to_try = [
		"res://assets/ingredientes/%s.png" % ingrediente,
		"res://assets/ingredientes/%s.tres" % ingrediente, 
		"res://assets/ingredientes/%s.tex" % ingrediente
	]
	
	var texture_loaded = false
	for path in paths_to_try:
		if ResourceLoader.exists(path):
			sprite_ingrediente.texture = load(path)
			sprite_ingrediente.scale = Vector2(0.25, 0.25)
			sprite_ingrediente.visible = true
			texture_loaded = true
			break
	
	if not texture_loaded:
		push_warning("No se encontró textura para el ingrediente: ", ingrediente)
		sprite_ingrediente.visible = false

func recoger_ingrediente() -> String:
	return ingrediente
