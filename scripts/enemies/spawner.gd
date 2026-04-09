extends Area2D

class_name Spawner

const MAX_HEALTH: int = 14
var health: int = MAX_HEALTH
@onready var spawn_timer: float = randf_range(1.0, 2.0)
var max_dist: float = 200.0

@export var explosion_scene: PackedScene
@onready var player: Player = $/root/Main/Player
@onready var level: Level = get_node_or_null("/root/Main/Level")

func _ready() -> void:
	$Healthbar.hide()

func spawn() -> void:
	if level:
		var randval: float = randf_range(0.0, level.total_weight)	
		var count: int = randi_range(1, 3)
		for i in range(count):
			var id: String = ""
			for enemy_id in level.weights:
				randval -= level.weights[enemy_id]
				if randval <= 0.0:
					id = enemy_id
					break
			level.spawn_enemy(id, level.get_tile_pos(global_position))

func _process(delta: float) -> void:
	if health <= 0:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.scale *= 0.4
		explosion.modulate.a = 0.5
		if level:
			SfxManager.play_at("explosion", global_position, level)
			level.add_child(explosion)
		player.add_score(320)
		spawn()
		queue_free()
		return

	$Healthbar.update_bar(health, MAX_HEALTH)

	if player.health <= 0:
		return

	if (global_position - player.global_position).length() > max_dist:
		return

	spawn_timer -= delta
	if spawn_timer < 0.0:
		spawn_timer = randf_range(9.0, 12.0)
		spawn()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet") and area is Bullet:
		area.explode()
		health -= 1
		max_dist = 480.0
		spawn_timer -= 0.5
