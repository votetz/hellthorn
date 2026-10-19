extends Node2D

@onready var damage_flash: ColorRect = $CanvasLayer/DamageFlash
var damage_flash_tween: Tween


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/hud/main_menu.tscn")


func _on_player_health_changed(current: int, previous: int) -> void:
	if current >= previous:
		return

	if damage_flash_tween and damage_flash_tween.is_running():
		damage_flash_tween.kill()

	damage_flash.color.a = 0.35
	damage_flash_tween = create_tween()
	damage_flash_tween.tween_property(damage_flash, "color:a", 0.0, 0.25)
