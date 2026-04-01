extends Control

class_name HUD

func set_hp(health: int, max_health: int) -> void:
	if max_health == 0:
		$HP.hide()
		return
	$HP.show()
	$HP.text = "HP: %d/%d" % [ health, max_health ]

func show_game_over() -> void:
	$GameOver.show()

func hide_game_over() -> void:
	$GameOver.hide()
