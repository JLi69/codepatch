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
