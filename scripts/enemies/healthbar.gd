extends ColorRect

@export var healthbar_color: Color

func _ready() -> void:
	$ColorRect.color = healthbar_color

func update_bar(health: int, max_health: int) -> void:
	if health < max_health:
		show()
		$ColorRect.color = healthbar_color
	var perc: float = float(health) / float(max_health)
	$ColorRect.size.x = size.x * perc
