extends Area2D

class_name PlayerBullet

var speed: float = 240.0
var dir: Vector2 = Vector2.ZERO
var damage: int = 1

@export var explosion_scene: PackedScene

func _process(delta: float) -> void:
	position += delta * dir * speed

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
		var level: Level = get_node_or_null("/root/Main/Level")
		if level:
			var explosion: GPUParticles2D = explosion_scene.instantiate()
			explosion.global_position = global_position
			explosion.scale *= 0.3
			explosion.modulate = Color8(0xa6, 0xff, 0x00)
			level.add_child(explosion)
