class_name ContainerAnimation
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

enum OrderType{
	START_TOP,
	START_BOTTOM
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
@export var anim_when: AnimStartTrigger = AnimStartTrigger.VISIBLE
@export var anim_type: AnimType
@export var order_type: OrderType
@export var scale_from: ScaleFrom
@export var duration: float = 0.2
@export var delay_appear: float = 0.08
@export var delay_between_elements: float = 0.05
@export var change_visible: bool = false

var tween: Tween 

func _ready() -> void:
	
	if target == null:
		target = self
	
	match anim_type:
		AnimType.SCALE:
			for child: Control in target.get_children():
				child.scale = Vector2.ZERO
				set_pivot(child, scale_from)
				child.modulate.a = 0.0
		AnimType.SLIDE_IN_LEFT, AnimType.SLIDE_IN_RIGHT:
			for child: Control in target.get_children():
				child.modulate.a = 0.0
	
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
	for child: Control in target.get_children():
		set_pivot(child, scale_from)
	
	for child: Control in target.get_children():
		child.modulate.a = 0.0
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	
	if delay_appear > 0.0:
		tween.tween_interval(delay_appear)
		tween.chain().tween_interval(0.01)
	
	var children: Array = target.get_children()
	
	if order_type == OrderType.START_BOTTOM:
		children.reverse()
	
	var idx: int = 0
	for child: Control in children:
		if anim_type == AnimType.SCALE:
			tween.tween_property(child, "scale", Vector2.ONE, duration).from(Vector2.ZERO).set_delay(delay_between_elements * idx)
			tween.tween_property(child, "modulate:a", 1.0, 0.01).set_delay(delay_between_elements * idx)
		elif anim_type == AnimType.SLIDE_IN_LEFT:
			tween.tween_property(child, "position:x", child.position.x, duration).from(child.position.x - child.size.x).set_delay(delay_between_elements * idx)
			tween.tween_property(child, "modulate:a", 1.0, 0.01).set_delay(delay_between_elements * idx)
		elif anim_type == AnimType.SLIDE_IN_RIGHT:
			tween.tween_property(child, "position:x", child.position.x, duration).from(child.position.x + child.size.x).set_delay(delay_between_elements * idx)
			tween.tween_property(child, "modulate:a", 1.0, 0.01).set_delay(delay_between_elements * idx)
		
		idx += 1

func _on_visibility_changed():
	if visible and anim_when == AnimStartTrigger.VISIBLE:
		appear()
