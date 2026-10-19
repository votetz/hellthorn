extends CharacterBody2D


@onready var pistol: Pistol = $Pistol


@export var speed: float = 180.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var direction := global_position.direction_to(get_global_mouse_position())
		pistol.shoot(direction)
	elif event.is_action_pressed("reload"):
		pistol.reload()

func _on_health_component_died() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/hud/main_menu.tscn")
