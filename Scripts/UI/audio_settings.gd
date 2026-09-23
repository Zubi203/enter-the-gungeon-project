extends Control

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider

var master_index: int
var sfx_index: int
var music_index: int

func _ready() -> void:
	master_index = AudioServer.get_bus_index("Master")
	sfx_index = AudioServer.get_bus_index("SFX")
	music_index = AudioServer.get_bus_index("Music")
	
	master_slider.value = get_volume(master_index)
	sfx_slider.value = get_volume(sfx_index)
	music_slider.value = get_volume(music_index)


func get_volume(bus_index: int) -> float:
	var volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume)

func set_volume(bus_index: int, volume: float):
	var db_volume = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_volume)

func _on_master_slider_value_changed(value: float) -> void:
	set_volume(master_index, value)


func _on_music_slider_value_changed(value: float) -> void:
	set_volume(music_index, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	set_volume(sfx_index, value)
