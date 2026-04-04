extends AnimatedSprite2D

@onready var viewrect: Rect2 = get_viewport().get_visible_rect()

func _process(delta: float) -> void:
	if (position.x < -64.0 or position.y < -64.0) and visible:
		queue_free()
		return

	if (position.x > viewrect.size.x + 64.0 or position.y > viewrect.size.y + 64.0) and visible:
		queue_free()
		return

	position += Vector2(cos(rotation - PI / 2.0), sin(rotation - PI / 2.0)) * 60.0 * delta
