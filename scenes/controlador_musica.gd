extends Node

@onready var music_player := AudioStreamPlayer.new()

var music_started := false

func _ready():
	if not music_player.is_inside_tree():
		add_child(music_player)

	music_player.bus = "Music"
	music_player.stream = preload("res://assets/audio/ChillLofiR.mp3")
	music_player.volume_db = -10  # Opcional: volumen más bajo

	if not music_started:
		music_player.play()
		music_started = true
