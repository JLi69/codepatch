extends AudioStreamPlayer2D

class_name Sfx

func _ready() -> void:
	play()
	connect("finished", queue_free)

