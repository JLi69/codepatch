extends Sprite2D

@onready var player: Player = get_parent()
@onready var radius: float = position.length()
@onready var size: float = scale.y

@export var player_bullet_scene: PackedScene

var shoot_cooldown: float = 0.0

func update_transform() -> void:
	position = (get_global_mouse_position() - player.global_position).normalized() * radius
	rotation = (get_global_mouse_position() - player.global_position).normalized().angle()
	if abs(rotation) < PI / 2:
		scale.y = size
	else:
		scale.y = -size

func _process(delta: float) -> void:
	if player.health <= 0 or !player.can_move:
		return

	update_transform()

	# Shoot bullets
	shoot_cooldown = max(shoot_cooldown - delta, 0.0)
	if shoot_cooldown <= 0.0 and Input.is_action_pressed("shoot"):
		shoot_cooldown = player.shoot_cooldown
		var bullet: Bullet = player_bullet_scene.instantiate()
		bullet.global_position = $BulletSpawn.global_position
		bullet.dir = Vector2(cos(rotation), sin(rotation))
		bullet.speed += player.speed
		var level = get_node_or_null("/root/Main/Level")
		if level:
			level.add_child(bullet)
