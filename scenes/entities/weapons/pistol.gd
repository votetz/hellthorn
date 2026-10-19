extends Node2D
class_name Pistol

@export var bullet_scene: PackedScene
@export var magazine_size: int = 17
@export var reserve_ammo: int = 51
@export var fire_interval: float = 0.25
@export var reload_time: float = 1.3

var ammo_in_magazine: int
var cooldown: float = 0.0
var reloading: bool = false

func _ready() -> void:
	ammo_in_magazine = magazine_size

func _process(delta: float) -> void:
	cooldown = maxf(cooldown - delta, 0.0)

func shoot(direction: Vector2) -> void:
	if reloading or cooldown > 0.0 or ammo_in_magazine <= 0:
		return
	if direction == Vector2.ZERO or bullet_scene == null:
		return

	var bullet := bullet_scene.instantiate() as Bullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + direction.normalized() * 8.0
	bullet.direction = direction.normalized()
	ammo_in_magazine -= 1
	cooldown = fire_interval

func reload() -> void:
	if reloading or ammo_in_magazine >= magazine_size or reserve_ammo <= 0:
		return
	reloading = true
	await get_tree().create_timer(reload_time).timeout

	var needed := magazine_size - ammo_in_magazine
	var loaded := mini(needed, reserve_ammo)
	ammo_in_magazine += loaded
	reserve_ammo -= loaded
	reloading = false
