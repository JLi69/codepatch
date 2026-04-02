extends Bug

func shoot() -> void:
	var bullet_count: int = randi_range(3, 5)
	var spread: float = randf_range(PI / 4.0, PI / 3.0)
	for i in range(bullet_count):
		var offset: float = (i - (bullet_count - 1) / 2.0) / float(bullet_count - 1) * spread
		shoot_bullet(offset)
