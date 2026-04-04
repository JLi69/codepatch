extends Control

func _on_back_pressed() -> void:
	$/root/Main.play_sfx("Click")
	save_settings()
	hide()

func show_reset() -> void:
	$ScrollContainer/VBoxContainer/ResetContainer.show()

func hide_reset() -> void:
	$ScrollContainer/VBoxContainer/ResetContainer.hide()

func actviate() -> void:
	show()
	$ScrollContainer/VBoxContainer/Confirm.hide()
	
	# Set the volume sliders
	var master_index: int = AudioServer.get_bus_index("Master")
	var master_slider: Slider = $ScrollContainer/VBoxContainer/MasterVolume/MasterSlider
	master_slider.value = AudioServer.get_bus_volume_linear(master_index) * master_slider.max_value
	$ScrollContainer/VBoxContainer/MasterVolume/Label.text = "Master Volume (%d%%)" % int(master_slider.value)

	var sfx_index: int = AudioServer.get_bus_index("Sfx")
	var sfx_slider: Slider = $ScrollContainer/VBoxContainer/SfxVolume/SfxSlider
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_index) * sfx_slider.max_value
	$ScrollContainer/VBoxContainer/SfxVolume/Label.text = "SFX Volume (%d%%)" % int(sfx_slider.value)

	var music_index: int = AudioServer.get_bus_index("Music")
	var music_slider: Slider = $ScrollContainer/VBoxContainer/MusicVolume/MusicSlider
	music_slider.value = AudioServer.get_bus_volume_linear(music_index) * music_slider.max_value
	$ScrollContainer/VBoxContainer/MusicVolume/Label.text = "Music Volume (%d%%)" % int(music_slider.value)

func _on_reset_pressed() -> void:
	$/root/Main.play_sfx("Click")
	hide_reset()
	$ScrollContainer/VBoxContainer/Confirm.show()

func _on_confirm_reset_pressed() -> void:
	$/root/Main.play_sfx("Click")
	DirAccess.remove_absolute("user://save")
	$/root/Main.high_score = 0
	hide()

func _on_cancel_pressed() -> void:
	$/root/Main.play_sfx("Click")
	show_reset()
	$ScrollContainer/VBoxContainer/Confirm.hide()

func _on_master_slider_value_changed(value: float) -> void:
	var index: int = AudioServer.get_bus_index("Master")
	var slider: Slider = $ScrollContainer/VBoxContainer/MasterVolume/MasterSlider
	AudioServer.set_bus_volume_db(index, linear_to_db(value / slider.max_value))
	$ScrollContainer/VBoxContainer/MasterVolume/Label.text = "Master Volume (%d%%)" % int(value)

func _on_sfx_slider_value_changed(value: float) -> void:
	var index: int = AudioServer.get_bus_index("Sfx")
	var slider: Slider = $ScrollContainer/VBoxContainer/SfxVolume/SfxSlider
	AudioServer.set_bus_volume_db(index, linear_to_db(value / slider.max_value))
	$ScrollContainer/VBoxContainer/SfxVolume/Label.text = "SFX Volume (%d%%)" % int(value)

func _on_music_slider_value_changed(value: float) -> void:
	var index: int = AudioServer.get_bus_index("Music")
	var slider: Slider = $ScrollContainer/VBoxContainer/MusicVolume/MusicSlider
	AudioServer.set_bus_volume_db(index, linear_to_db(value / slider.max_value))
	$ScrollContainer/VBoxContainer/MusicVolume/Label.text = "Music Volume (%d%%)" % int(value)

func _on_reset_settings_pressed() -> void:
	var master_index: int = AudioServer.get_bus_index("Master")
	var sfx_index: int = AudioServer.get_bus_index("Sfx")
	var music_index: int = AudioServer.get_bus_index("Music")

	# Reset the audio
	AudioServer.set_bus_volume_linear(master_index, 1.0)
	AudioServer.set_bus_volume_linear(sfx_index, 1.0)
	AudioServer.set_bus_volume_linear(music_index, 1.0)
	
	# Reset the sliders
	var master_slider: Slider = $ScrollContainer/VBoxContainer/MasterVolume/MasterSlider
	master_slider.value = AudioServer.get_bus_volume_linear(master_index) * master_slider.max_value
	$ScrollContainer/VBoxContainer/MasterVolume/Label.text = "Master Volume (%d%%)" % int(master_slider.value)

	var sfx_slider: Slider = $ScrollContainer/VBoxContainer/SfxVolume/SfxSlider
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_index) * sfx_slider.max_value
	$ScrollContainer/VBoxContainer/SfxVolume/Label.text = "SFX Volume (%d%%)" % int(sfx_slider.value)

	var music_slider: Slider = $ScrollContainer/VBoxContainer/MusicVolume/MusicSlider
	music_slider.value = AudioServer.get_bus_volume_linear(music_index) * music_slider.max_value
	$ScrollContainer/VBoxContainer/MusicVolume/Label.text = "Music Volume (%d%%)" % int(music_slider.value)

	$/root/Main.play_sfx("Click")

func save_settings() -> void:
	var master_index: int = AudioServer.get_bus_index("Master")
	var sfx_index: int = AudioServer.get_bus_index("Sfx")
	var music_index: int = AudioServer.get_bus_index("Music")

	var settings: ConfigFile = ConfigFile.new()
	settings.set_value("volume", "master_volume", AudioServer.get_bus_volume_linear(master_index))
	settings.set_value("volume", "sfx_volume", AudioServer.get_bus_volume_linear(sfx_index))
	settings.set_value("volume", "music_volume", AudioServer.get_bus_volume_linear(music_index))
	settings.save("user://settings.cfg")
