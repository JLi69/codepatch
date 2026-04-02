extends Control

class_name HUD

func set_hp(health: int, max_health: int) -> void:
	if max_health == 0:
		$HP.hide()
		return
	$HP.show()
	$HP.text = "HP: %d/%d" % [ health, max_health ]

func set_score(score: int) -> void:
	if score == 1:
		$Score.text = "1 bit" % score
	else:
		$Score.text = "%d bits" % score

func set_patch_files(patch_files: int) -> void:
	$PatchFiles.text = "%d/3" % patch_files

func show_game_over() -> void:
	$GameOver.show()

func hide_game_over() -> void:
	$GameOver.hide()

func set_time(time: float) -> void:
	var seconds: int = int(fmod(time, 60.0))
	var minutes: int = int(time / 60.0)
	if seconds >= 10:
		$Timer.text = "%d:%d" % [ minutes, seconds ]
	else:
		$Timer.text = "%d:0%d" % [ minutes, seconds ]

func set_survive_timer(time: float, run_timer: bool) -> void:
	if !run_timer or time <= 0.0:
		$Survive.hide()
		return
	$Survive.show()
	$Survive.text = "Survive! %ds" % int(time)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$Pause.visible = !$Pause.visible
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if $Pause.visible:
		$GameOver.hide()
	else:
		if $/root/Main/Player.health <= 0 and !$GameOver.visible:
			show_game_over()
		elif $/root/Main/Player.health > 0:
			hide_game_over()

func _on_return_pressed() -> void:
	$Pause.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
