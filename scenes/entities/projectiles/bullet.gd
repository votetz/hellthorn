extends Area2D

class_name Bullet

@export var damage: int = 10
@export var speed: float = 1800.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var next_position := global_position + direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(
		global_position, next_position, collision_mask
	)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		var collider := hit["collider"] as Node2D
		if collider != null:
			var hurtbox := collider.get_node_or_null("Hurtbox")
			if hurtbox != null:
				hurtbox.call("receive_damage", damage)

		queue_free()
		return

	global_position = next_position
