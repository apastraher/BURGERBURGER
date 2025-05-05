extends Area2D
class_name CajaIngrediente

@export var ingrediente: String
@onready var sprite_ingrediente: Sprite2D = $Ingrediente

func _ready():
	cargar_textura_ingrediente()

func cargar_textura_ingrediente():
	var path = "res://assets/ingredientes/%s.png" % ingrediente
	if ResourceLoader.exists(path):
		sprite_ingrediente.texture = load(path)
		# Ajustar escala si es necesario (opcional)
		sprite_ingrediente.scale = Vector2(0.5, 0.5)  
	else:
		push_warning("No se encontró textura para: ", path)
		sprite_ingrediente.visible = false

func recoger_ingrediente() -> String:
	# Pequeña animación al recoger (opcional)
	var tween = create_tween()
	tween.tween_property(sprite_ingrediente, "scale", Vector2(0.6, 0.6), 0.1)
	tween.tween_property(sprite_ingrediente, "scale", Vector2(0.5, 0.5), 0.1)
	
	return ingrediente
