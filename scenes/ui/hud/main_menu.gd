extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_h_slider_value_changed($CenterContainer/SettingsPanel/HSlider.value)
	for button in [$CenterContainer/MainPanel/Button_Play, $CenterContainer/MainPanel/Button_Settings, $CenterContainer/MainPanel/Button_Exit]:
		button.mouse_entered.connect(_on_menu_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_menu_button_mouse_exited.bind(button))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_exit_pressed() -> void:
	get_tree().quit()


func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
	
func _on_button_settings_pressed() -> void:
	$CenterContainer/MainPanel.hide()
	$CenterContainer/SettingsPanel.show()
	
func _on_h_slider_value_changed(value: float) -> void:
	$CenterContainer/SettingsPanel/Label_Volume.text = "Volume: %d%%" % roundi(value)

	var volume := maxf(value / 100.0, 0.001)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(volume)
	)


func _on_button_back_pressed() -> void:
	$CenterContainer/SettingsPanel.hide()
	$CenterContainer/MainPanel.show()


var hover_tweens: Dictionary = {}


func _on_menu_button_mouse_entered(button: Control) -> void:
	animate_button(button, Vector2(1.06, 1.06))


func _on_menu_button_mouse_exited(button: Control) -> void:
	animate_button(button, Vector2.ONE)


func animate_button(button: Control, target_scale: Vector2) -> void:
	var previous_tween: Tween = hover_tweens.get(button)
	if previous_tween and previous_tween.is_running():
		previous_tween.kill()
	var tween := create_tween()
	hover_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, 0.12) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
