extends Node
class_name EnemyState

signal transition_requested(state_name: StringName)


func player_detected() -> void:
	transition_requested.emit(&"Chase")


func set_destination(_position: Vector2) -> void:
	pass


func enter(_enemy: CharacterBody2D) -> void:
	pass


func physics_update(_enemy: CharacterBody2D, _delta: float) -> void:
	pass


func exit(_enemy: CharacterBody2D) -> void:
	pass
