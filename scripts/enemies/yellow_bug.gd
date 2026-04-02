extends Bug

var speed_timer: float = 0.0
const SPEED_DIST: float = 120.0

func calculate_velocity() -> Vector2:
	if (global_position - player.global_position).length() > SPEED_DIST and speed_timer <= 0.0:
		return super.calculate_velocity() * 1.75
	return super.calculate_velocity()

func _process(delta: float) -> void:
	super._process(delta)
	if (global_position - player.global_position).length() <= SPEED_DIST:
		speed_timer = 1.5
	if speed_timer > 0.0:
		speed_timer -= delta
