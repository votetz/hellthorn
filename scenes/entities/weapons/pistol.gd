extends Node2D
class_name Pistol

const DROPPED_MAGAZINE_SCENE: PackedScene = preload(
	"res://scenes/entities/weapons/dropped_magazine.tscn"
)
const SHOT_SOUND_START: float = 0.05

@export var bullet_scene: PackedScene
@export var magazine_size: int = 17
@export var reserve_ammo: int = 51
@export var fire_interval: float = 0.25
@export var reload_time: float = 1.3

var ammo_in_magazine: int
var cooldown: float = 0.0
var reloading: bool = false

@onready var shot_player: AudioStreamPlayer2D = $ShotPlayer
@onready var empty_player: AudioStreamPlayer2D = $EmptyPlayer
@onready var reload_player: AudioStreamPlayer2D = $ReloadPlayer

func _ready() -> void:
	ammo_in_magazine = magazine_size

func _process(delta: float) -> void:
	cooldown = maxf(cooldown - delta, 0.0)

func shoot(direction: Vector2) -> void:
	if reloading or cooldown > 0.0:
		return
	if ammo_in_magazine <= 0:
		if empty_player.stream != null:
			empty_player.play()
		cooldown = fire_interval
		return
	if direction == Vector2.ZERO or bullet_scene == null:
		return

	ammo_in_magazine -= 1
	cooldown = fire_interval
	if shot_player.stream != null:
		shot_player.play(SHOT_SOUND_START)

	var bullet := bullet_scene.instantiate() as Bullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + direction.normalized() * 8.0
	bullet.direction = direction.normalized()

func reload() -> void:
	if reloading or ammo_in_magazine >= magazine_size or reserve_ammo <= 0:
		return
	reloading = true
	drop_magazine()
	if reload_player.stream != null:
		reload_player.play()
	await get_tree().create_timer(reload_time).timeout

	var needed := magazine_size - ammo_in_magazine
	var loaded := mini(needed, reserve_ammo)
	ammo_in_magazine += loaded
	reserve_ammo -= loaded
	reloading = false

func drop_magazine() -> void:
	var magazine := DROPPED_MAGAZINE_SCENE.instantiate() as Sprite2D
	get_tree().current_scene.add_child(magazine)

	var forward := global_transform.x.normalized()
	var sideways := forward.orthogonal()
	magazine.global_position = global_position - forward * 5.0 + sideways * 3.0
	magazine.global_rotation = global_rotation + PI / 2.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(
		magazine, "global_position", magazine.global_position + sideways * 18.0 + forward * 4.0, 0.38
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		magazine, "global_rotation", magazine.global_rotation + 1.6, 0.38
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(magazine, "scale", Vector2(0.11, 0.11), 0.38)
