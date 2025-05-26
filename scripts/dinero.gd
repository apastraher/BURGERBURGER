extends Node2D

var dinero: int = 0

@onready var label = $MoneyLabel

func _ready():
	actualizar_label()

func ganar_dinero(cantidad: int):
	dinero += cantidad
	actualizar_label()

func actualizar_label():
	label.text = str(dinero)
