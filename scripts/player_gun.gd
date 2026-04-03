extends Sprite2D

@onready var player: Player = get_parent()
@onready var radius: float = position.length()
@onready var size: float = scale.y

@export var player_bullet_scene: PackedScene

var shoot_cooldown: float = 0.0

# Code taken from The Legend of the Lawns 
# (https://github.com/Birb-Games/the-legend-of-the-lawns)
# from the water gun script, credit: gldeA
func update_transform() -> void:
	position = (get_global_mouse_position() - player.global_position).normalized() * radius
	rotation = (get_global_mouse_position() - player.global_position).normalized().angle()
	if abs(rotation) < PI / 2:
		scale.y = size
	else:
		scale.y = -size

func shoot_bullet(angle_offset: float = 0.0) -> void:
	var bullet: Bullet = player_bullet_scene.instantiate()
	bullet.global_position = $BulletSpawn.global_position
	bullet.dir = Vector2(cos(rotation + angle_offset), sin(rotation + angle_offset))
	bullet.speed += player.speed
	bullet.damage = player.bullet_damage
	var level = get_node_or_null("/root/Main/Level")
	if level:
		level.add_child(bullet)

func _process(delta: float) -> void:
	if player.health <= 0 or !player.can_move:
		return

	update_transform()

	# Shoot bullets
	shoot_cooldown = max(shoot_cooldown - delta, 0.0)
	if shoot_cooldown <= 0.0 and Input.is_action_pressed("shoot"):
		shoot_cooldown = player.shoot_cooldown
		var bullet_count: int = player.bullet_count
		var spread: float = clamp(deg_to_rad(player.bullet_spread), 0.0, 2.0 * PI)
		if player.multishots_left > 0:
			player.multishots_left -= 1
			bullet_count = ceili(bullet_count * randf_range(1.25, 2.5))
		if bullet_count == 1:
			shoot_bullet()
		else:
			for i in range(bullet_count):
				var frac: float = (i - (bullet_count - 1) / 2.0) / float(bullet_count - 1)
				var angle_offset: float = frac * spread
				shoot_bullet(angle_offset)
