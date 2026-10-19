extends EnemyState

@export var search_speed: float = 110.0
@export var search_duration: float = 3.0
@export var arrival_distance: float = 8.0

var destination: Vector2
var elapsed: float = 0.0


func set_destination(position: Vector2) -> void:
	destination = position


func enter(_enemy: CharacterBody2D) -> void:
	elapsed = 0.0


func physics_update(enemy: CharacterBody2D, delta: float) -> void:
	elapsed += delta
	if elapsed >= search_duration:
		transition_requested.emit(&"Patrol")
		return

	if enemy.global_position.distance_to(destination) > arrival_distance:
		enemy.velocity = enemy.global_position.direction_to(destination) * search_speed
