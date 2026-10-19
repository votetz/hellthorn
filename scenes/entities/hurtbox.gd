extends Area2D

@onready var health: HealthComponent = $"../HealthComponent"


func receive_damage(amount: int) -> void:
	health.take_damage(amount)
