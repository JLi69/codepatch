extends Control

func _on_back_pressed() -> void:
	hide()

func show_reset() -> void:
	$ScrollContainer/VBoxContainer/Reset.show()

func hide_reset() -> void:
	$ScrollContainer/VBoxContainer/Reset.hide()

func actviate() -> void:
	show()
	$ScrollContainer/VBoxContainer/Confirm.hide()

func _on_reset_pressed() -> void:
	$ScrollContainer/VBoxContainer/Reset.hide()
	$ScrollContainer/VBoxContainer/Confirm.show()

func _on_confirm_reset_pressed() -> void:
	DirAccess.remove_absolute("user://save")
	$/root/Main.high_score = 0
	hide()

func _on_cancel_pressed() -> void:
	$ScrollContainer/VBoxContainer/Reset.show()
	$ScrollContainer/VBoxContainer/Confirm.hide()

