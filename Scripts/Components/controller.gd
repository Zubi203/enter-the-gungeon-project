@abstract
class_name ControllerComponent
extends Node2D

signal MoveInput (direction: Vector2)
signal ChangeSpeed (new_speed: float)
signal DodgeRoll (direction: Vector2, duration: float)
signal ActivateImmunityFrames (duration: float)

@export var dodge_roll_duration: float = 0.7
var dodge_roll_duration_countdown: float

@export var hit_iframe_duration: float = 0.4
