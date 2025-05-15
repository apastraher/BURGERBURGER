extends CanvasLayer

signal fade_completed

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var ready_completed := false

func _ready() -> void:
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.hide()
	call_deferred("_delayed_init")

func _delayed_init():
	_update_rect_size()
	get_viewport().size_changed.connect(_update_rect_size)
	ready_completed = true

func _update_rect_size():
	if is_instance_valid(color_rect):
		color_rect.size = get_viewport().size

func fade_in(duration: float = 1.0) -> void:
	if not ready_completed:
		await get_tree().process_frame
	
	color_rect.show()
	
	if anim_player.has_animation("fade_in"):
		anim_player.speed_scale = 1.0 / duration
		anim_player.play("fade_in")
		await anim_player.animation_finished
	else:
		var tween = create_tween()
		tween.tween_property(color_rect, "color:a", 1.0, duration)
		await tween.finished
	
	emit_signal("fade_completed")

func fade_out(duration: float = 1.0) -> void:
	if not ready_completed:
		await get_tree().process_frame
	
	if anim_player.has_animation("fade_out"):
		anim_player.speed_scale = 1.0 / duration
		anim_player.play("fade_out")
		await anim_player.animation_finished
	else:
		var tween = create_tween()
		tween.tween_property(color_rect, "color:a", 0.0, duration)
		await tween.finished
	
	color_rect.hide()
	emit_signal("fade_completed")
