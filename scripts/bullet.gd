extends Area2D

class_name Bullet

var speed: float = 240.0
var dir: Vector2 = Vector2.ZERO
var damage: int = 1

@export var explosion_scene: PackedScene
@export var use_modulate_for_explosion: bool = false
@export var explosion_color: Color = Color.WHITE
@export var can_destroy_corruption: bool = false
@onready var level: Level = get_node_or_null("/root/Main/Level")

func _process(delta: float) -> void:
	position += delta * dir * speed
	rotation += 4.0 * PI * delta

	if can_destroy_corruption:
		if level.get_tile(level.get_tile_pos(global_position)) == level.CORRUPTED:
			level.set_tile(level.get_tile_pos(global_position), level.EMPTY)
			explode()

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		explode()

func explode() -> void:
	queue_free()
	var level: Level = get_node_or_null("/root/Main/Level")
	if level:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.scale *= 0.25
		if use_modulate_for_explosion:
			explosion.modulate = modulate
		else:
			explosion.modulate = explosion_color 
		level.add_child(explosion)
