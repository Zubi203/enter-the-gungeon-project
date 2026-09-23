extends CanvasLayer

signal ProgressChanged (progress)
signal LoadFinished

var loading_screen: PackedScene = preload("uid://dxredbr0k6ekp")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true
@export var minimum_load_time: float = 1.0
var load_time_elapsed: float = 0.0

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	set_process(false)

func transition(target_level: GlobalData.Scenes, current_level: GlobalData.Scenes):
	PauseManager.clear_all_menus()
	animation_player.play("fade_in")
	await get_tree().create_timer(0.8, true, false, true).timeout
	_change_scene(target_level, current_level)
	await LoadFinished
	await get_tree().create_timer(1.3, true, false, true).timeout
	animation_player.play("fade_out")
	
func _change_scene(target_level: GlobalData.Scenes, _current_level: GlobalData.Scenes):
	load_scene(GlobalData.SCENE_PATHS[target_level])
	GlobalData.current_scene = target_level


func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	ProgressChanged.connect(new_load_screen._on_progress_changed)
	LoadFinished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.LoadingScreenReady
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	load_time_elapsed = 1.0

func _process(_delta: float) -> void:
	
	if load_time_elapsed > 0.0:
		load_time_elapsed -= _delta * 1.0 / minimum_load_time
	else:
		load_time_elapsed = 0.0
		
	
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	ProgressChanged.emit(1.0 - load_time_elapsed)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			if load_time_elapsed <= 0:
				ProgressChanged.emit(progress[0])
				loaded_resource = ResourceLoader.load_threaded_get(scene_path)
				get_tree().change_scene_to_packed(loaded_resource)
				LoadFinished.emit()
