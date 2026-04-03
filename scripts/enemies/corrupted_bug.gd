extends Bug

var change_color_timer: float = 0.0
@onready var prev_tile_pos: Vector2i = level.get_tile_pos(global_position)

func _process(delta: float) -> void:
	super._process(delta)

	if level:
		var tile_pos: Vector2i = level.get_tile_pos(global_position)
		if level.get_tile(prev_tile_pos) == level.EMPTY and tile_pos != prev_tile_pos:
			level.set_tile(prev_tile_pos, level.CORRUPTED)
		prev_tile_pos = tile_pos
	
	change_color_timer -= delta
	if change_color_timer < 0.0:
		change_color_timer = 0.75
		modulate = Color8(
			randi_range(128, 255),
			randi_range(128, 255),
			randi_range(128, 255)
		)
