extends Bug

var rotation_dir: float = 1.0

func _ready() -> void:
	super._ready()
	if randi() % 2 == 0:
		rotation_dir *= -1.0
	speed *= randf_range(0.8, 1.1)
	rotation = 0.0

func calculate_velocity() -> Vector2:
	if player.health <= 0:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized() * speed

func _process(delta: float) -> void:
	super._process(delta)
	$AnimatedSprite2D.rotation += rotation_dir * PI * 1.5 * delta
