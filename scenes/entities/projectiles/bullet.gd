extends Area2D

class_name Bullet

@export var speed: float = 1800.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var next_position := global_position + direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(
		global_position, next_position, collision_mask
	)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		queue_free()
		return

	global_position = next_position
func _on_body_entered(_body: Node2D) -> void:
	queue_free()
