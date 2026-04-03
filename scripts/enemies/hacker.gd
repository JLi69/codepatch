extends Bug

var bullet_count: int = 1
var bullet_spread: float = PI / 3.0
@export var patch_file_scene: PackedScene
var default_max_chase_dist: float

func _ready() -> void:
	super._ready()
	speed = player.speed * player.DEFAULT_SPEED * 0.75
	max_health = ceili(player.max_health * 0.75)
	health = max_health
	bullet_cooldown = player.shoot_cooldown * 1.5
	bullet_count = player.bullet_count
	bullet_damage = player.bullet_damage
	bullet_spread = deg_to_rad(player.bullet_spread)
	rotation = 0.0
	default_max_chase_dist = max_chase_distance

func explode() -> void:
	super.explode()
	var patch_file = patch_file_scene.instantiate()
	patch_file.can_heal = true
	patch_file.global_position = global_position
	level.add_child(patch_file)

func _process(delta: float) -> void:
	super._process(delta)
	if health < max_health:
		max_chase_distance = default_max_chase_dist * 6.0

func shoot() -> void:
	if bullet_count == 1:
		shoot_bullet()
		return

	for i in range(bullet_count):
		var offset: float = (i - (bullet_count - 1) / 2.0) / float(bullet_count - 1) * bullet_spread
		shoot_bullet(offset)
