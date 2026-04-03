extends Area2D

@export var explosion_scene: PackedScene

var pulse_time: float = 0.0
var can_heal: bool = false
@onready var glow_offset: float = randf_range(0.0, 2.0 * PI)

func _process(delta: float) -> void:
	pulse_time += delta
	var size = 1.0 + sin(pulse_time * PI + glow_offset) * 0.25
	$Glow.scale = Vector2(size, size)

	size = 1.0 + sin(pulse_time * PI * 0.9 + glow_offset) * 0.125
	$Sprite2D.scale = Vector2(size, size)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		queue_free()
		var player: Player = area.get_parent()
		player.add_score(64)
		if can_heal:
			player.heal(int(player.max_health * 0.4))
		player.patch_files += 1
		
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.scale *= 0.4
		explosion.global_position = global_position
		var level: Level = get_node_or_null("/root/Main/Level")
		if level:
			if player.patch_files >= 3:
				level.enemy_spawn_timer = 2.0
				level.enemy_spawn_interval = 8.0
				level.corruption_timer = 3.0
				level.run_survive_timer = true
			level.add_child(explosion)

