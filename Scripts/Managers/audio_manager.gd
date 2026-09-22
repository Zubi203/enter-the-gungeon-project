class_name AudioManager
extends Node

var players: Array[AudioStreamPlayer]
@export var pitch_randomness: float = 0.1

func _enter_tree() -> void:
	ManagerRegistry.register("audio_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("audio_manager")

func play (sound: AudioStream, volume_db: float = 0.0):
	if sound == null:
		return
	
	var player: AudioStreamPlayer = _get_player()
	player.volume_db = volume_db
	player.stream = sound
	player.play()

func play_random_pitch(sound: AudioStream, volume_db: float = 0.0):
	if sound == null:
		return
	
	var player: AudioStreamPlayer = _get_player()
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale += randf_range(-pitch_randomness, pitch_randomness)
	player.play()

func _get_player() -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			player.pitch_scale = 1.0
			player.volume_db = 0.0
			return player
	
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	players.append(new_player)
	add_child(new_player)
	new_player.bus = "SFX"
	return new_player
