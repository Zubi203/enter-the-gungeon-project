class_name AutoAnimateUIComponent
extends Control

enum AnimStartTrigger{
	MANUAL,
	READY,
	VISIBLE
}

enum AnimType{
	SCALE,
	SLIDE_IN_LEFT,
	SLIDE_IN_RIGHT
}

enum ScaleFrom{
	CENTER,
	TOP_LEFT,
	TOP_RIGHT,
	MIDDLE_LEFT,
	MIDDLE_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

@export var target: Control = null
@export var anim_when: AnimStartTrigger
@export var anim_type: AnimType
@export var scale_from: ScaleFrom
@export var duration: float = 0.15

var tween: Tween 

func _ready() -> void:
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	target = get_parent()
	if not target is Control:
		return
	
	match anim_type:
		AnimType.SCALE:
			target.scale = Vector2.ZERO
			set_pivot(target, scale_from)
			target.modulate.a = 0.0
		AnimType.SLIDE_IN_LEFT, AnimType.SLIDE_IN_RIGHT:
			target.modulate.a = 0.0
	
	if anim_when == AnimStartTrigger.READY:
		appear.call_deferred()
	visibility_changed.connect(_on_visibility_changed)

func set_pivot(control: Control, pivot: ScaleFrom):
	match pivot:
		ScaleFrom.CENTER:
			control.pivot_offset = control.size / 2.0
		ScaleFrom.TOP_LEFT:
			pass
		ScaleFrom.TOP_RIGHT:
			control.pivot_offset.x = control.size.x
		ScaleFrom.MIDDLE_LEFT:
			control.pivot_offset.y = control.size.y / 2.0
		ScaleFrom.MIDDLE_RIGHT:
			control.pivot_offset.y = control.size.y / 2.0
			control.pivot_offset.x = control.size.x
		ScaleFrom.BOTTOM_LEFT:
			control.pivot_offset.y = control.size.y
		ScaleFrom.BOTTOM_RIGHT:
			control.pivot_offset.y = control.size.y
			control.pivot_offset.x = control.size.x

func appear():
	set_pivot(target, scale_from)
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	

	if anim_type == AnimType.SCALE:
		tween.tween_property(target, "scale", Vector2.ONE, duration).from(Vector2.ZERO)
		tween.tween_property(target, "modulate:a", 1.0, 0.01)
	elif anim_type == AnimType.SLIDE_IN_LEFT:
		tween.tween_property(target, "position:x", target.position.x, duration).from(target.position.x - target.size.x)
		tween.tween_property(target, "modulate:a", 1.0, 0.01)
	elif anim_type == AnimType.SLIDE_IN_RIGHT:
		tween.tween_property(target, "position:x", target.position.x, duration).from(target.position.x + target.size.x)
		tween.tween_property(target, "modulate:a", 1.0, 0.01)

func _on_visibility_changed():
	if visible and anim_when == AnimStartTrigger.VISIBLE:
		appear()
