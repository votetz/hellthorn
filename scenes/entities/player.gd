extends CharacterBody2D

@export var speed: float = 180.0
const BULLET_SCENE: PackedScene = preload(
	"res://scenes/entities/projectiles/bullet.tscn"
)
func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		shoot()


func shoot() -> void:
	var shot_direction := global_position.direction_to(get_global_mouse_position())
	if shot_direction == Vector2.ZERO:
		return

	var bullet := BULLET_SCENE.instantiate() as Bullet
	get_parent().add_child(bullet)
	bullet.global_position = global_position + shot_direction * 8.0
	bullet.direction = shot_direction


func _on_health_component_died() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/hud/main_menu.tscn")
