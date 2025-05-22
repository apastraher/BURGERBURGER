extends Node2D

@export var real_total_time: int = 600
@export var real_time_remaining: int = 600  # Se reiniciará en _ready()

@export var simulated_start = 43200  # 12:00:00
@export var simulated_end = 57600    # 16:00:00

@onready var label_timer: Label = $Label
@onready var timer: Timer = $Timer
@onready var ring_sound: AudioStreamPlayer2D = $SonidoFinal

signal tiempo_finalizado

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f2"):  # Tecla de debug para finalizar el tiempo
		real_time_remaining = 0
		_on_timer_timeout()

func _ready() -> void:
	# Reinicia variables
	real_time_remaining = real_total_time
	update_display(simulated_start)

	# Verifica conexión antes de conectar
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

	timer.wait_time = 1.0
	timer.start()

func update_display(seconds: float) -> void:
	label_timer.text = format_time(seconds)
	label_timer.queue_redraw()

func format_time(seconds: float) -> String:
	var total_sec = int(seconds)
	return "%02d:%02d" % [
		total_sec / 3600,
		(total_sec % 3600) / 60,
	]

func _on_timer_timeout() -> void:
	real_time_remaining -= 1

	var elapsed = real_total_time - real_time_remaining
	var simulated_time = simulated_start + (simulated_end - simulated_start) * (elapsed / float(real_total_time))
	update_display(simulated_time)

	if real_time_remaining <= 0:
		timer.stop()
		update_display(simulated_end)

		if ring_sound and not ring_sound.playing:
			ring_sound.play()

		emit_signal("tiempo_finalizado")
