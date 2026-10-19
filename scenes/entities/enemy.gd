extends CharacterBody2D

const ENEMY_BULLET_SCENE: PackedScene = preload(
	"res://scenes/entities/projectiles/enemy_bullet.tscn"
)

@export var chase_speed: float = 150.0
@export var attack_range: float = 80.0
@export var attack_exit_margin: float = 20.0
@export var fire_interval: float = 0.8
@export var search_turn_speed: float = 1.5
@export var show_debug_ranges: bool = true

@onready var vision_cone: Area2D = $VisionCone
@onready var vision_polygon: CollisionPolygon2D = $VisionCone/CollisionPolygon2D
@onready var vision_debug_polygon: Polygon2D = $VisionCone/DebugPolygon
@onready var vision_debug_outline: Line2D = $VisionCone/DebugOutline
@onready var patrol_state: EnemyState = $StateMachine/Patrol
@onready var chase_state: EnemyState = $StateMachine/Chase
@onready var attack_state: EnemyState = $StateMachine/Attack
@onready var search_state: EnemyState = $StateMachine/Search

var current_state: EnemyState
var target: Node2D
var fire_cooldown: float = 0.0
var last_seen_position: Vector2


func _ready() -> void:
	vision_debug_polygon.polygon = vision_polygon.polygon
	var outline_points: PackedVector2Array = vision_polygon.polygon
	outline_points.append(outline_points[0])
	vision_debug_outline.points = outline_points
	vision_debug_polygon.visible = show_debug_ranges
	vision_debug_outline.visible = show_debug_ranges
	queue_redraw()

	for state in $StateMachine.get_children():
		state.transition_requested.connect(_on_state_transition_requested)
	change_state(patrol_state)
	vision_cone.body_entered.connect(_on_vision_cone_body_entered)
	vision_cone.body_exited.connect(_on_vision_cone_body_exited)


func _draw() -> void:
	if not show_debug_ranges:
		return

	draw_circle(Vector2.ZERO, attack_range, Color(1.0, 0.15, 0.1, 0.12))
	draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 64, Color(1.0, 0.2, 0.15, 0.8), 2.0)


func _physics_process(delta: float) -> void:
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	velocity = Vector2.ZERO

	if is_instance_valid(target):
		if is_inside_vision_cone(target):
			last_seen_position = target.global_position
		var distance := global_position.distance_to(target.global_position)
		var attack_threshold: float = attack_range
		if current_state == attack_state:
			attack_threshold += maxf(attack_exit_margin, 0.0)

		if distance <= attack_threshold:
			change_state(attack_state)
			if distance <= attack_range and fire_cooldown <= 0.0:
				shoot_at_target()
				fire_cooldown = fire_interval
		else:
			change_state(chase_state)
			velocity = global_position.direction_to(target.global_position) * chase_speed
	else:
		if current_state == chase_state or current_state == attack_state:
			start_search()
		current_state.physics_update(self, delta)

	var facing_direction: Vector2 = velocity
	if is_instance_valid(target):
		facing_direction = global_position.direction_to(target.global_position)
	if facing_direction != Vector2.ZERO:
		vision_cone.rotation = facing_direction.angle() - PI
	elif current_state == search_state:
		vision_cone.rotation += search_turn_speed * delta

	move_and_slide()


func start_search() -> void:
	search_state.set_destination(last_seen_position)
	change_state(search_state)


func is_inside_vision_cone(body: Node2D) -> bool:
	var local_position: Vector2 = vision_cone.to_local(body.global_position)
	return Geometry2D.is_point_in_polygon(local_position, vision_polygon.polygon)


func change_state(next_state: EnemyState) -> void:
	if current_state == next_state:
		return

	var previous_state_name: String = "None"
	if current_state != null:
		previous_state_name = current_state.name
	print("[Enemy] State: %s -> %s" % [previous_state_name, next_state.name])

	if current_state != null:
		current_state.exit(self)

	current_state = next_state
	current_state.enter(self)


func shoot_at_target() -> void:
	var shot_direction := global_position.direction_to(target.global_position)
	if shot_direction == Vector2.ZERO:
		return

	var bullet := ENEMY_BULLET_SCENE.instantiate() as Bullet
	get_parent().add_child(bullet)
	bullet.global_position = global_position + shot_direction * 8.0
	bullet.direction = shot_direction


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		last_seen_position = body.global_position
		if current_state == patrol_state or current_state == search_state:
			current_state.player_detected()


func _on_state_transition_requested(state_name: StringName) -> void:
	var next_state := $StateMachine.get_node_or_null(NodePath(state_name)) as EnemyState
	if next_state != null:
		change_state(next_state)


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == target:
		if is_inside_vision_cone(body):
			return
		target = null
		start_search()


func _on_health_component_died() -> void:
	queue_free()
