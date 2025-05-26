extends Control

@onready var hover_sound = $HoverSoundPlayer
@onready var sonido_button = $CanvasLayer/MarginContainer/VBoxContainer/Sonido
@onready var controles_button = $CanvasLayer/MarginContainer/VBoxContainer/Controles
@onready var atras_button = $CanvasLayer/Panel/Atras

func _ready():
	$CanvasLayer/MarginContainer/VBoxContainer/Sonido.grab_focus()

	for button in [sonido_button, controles_button, atras_button]:
		button.mouse_entered.connect(_on_button_hovered)

func _on_button_hovered():
	hover_sound.play()

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_sonido_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opciones_sonido.tscn")

func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opciones_controles.tscn")
