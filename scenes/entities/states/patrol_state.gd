extends EnemyState

@export var patrol_speed: float = 80.0
@export var arrival_distance: float = 8.0
@export var patrol_offsets: PackedVector2Array = PackedVector2Array([
	Vector2(-70.0, 0.0),
	Vector2(70.0, 0.0),
])

var origin: Vector2
var has_origin: bool = false
var waypoint_index: int = 0


func enter(enemy: CharacterBody2D) -> void:
	if not has_origin:
		origin = enemy.global_position
		has_origin = true


func physics_update(enemy: CharacterBody2D, _delta: float) -> void:
	if patrol_offsets.is_empty():
		return

	var destination: Vector2 = origin + patrol_offsets[waypoint_index]
	if enemy.global_position.distance_to(destination) <= arrival_distance:
		waypoint_index = (waypoint_index + 1) % patrol_offsets.size()
		return

	enemy.velocity = enemy.global_position.direction_to(destination) * patrol_speed
