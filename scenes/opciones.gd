extends Control

func _ready():
	$CanvasLayer/MarginContainer/VBoxContainer/Sonido.grab_focus()

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_sonido_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opciones_sonido.tscn")

func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opciones_controles.tscn")
