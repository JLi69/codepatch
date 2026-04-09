extends CharacterBody2D

class_name Player

# Default stats
const DEFAULT_SPEED: float = 96.0
const DEFAULT_MAX_HEALTH: int = 32
const DEFAULT_SHOOT_COOLDOWN: float = 0.5
const DEFAULT_BULLET_SPREAD: float = 60.0

# Stats that can be upgraded
var speed: float = 1.0
var max_health: int = DEFAULT_MAX_HEALTH
var shoot_cooldown: float = DEFAULT_SHOOT_COOLDOWN
var bullet_count: int = 1
var bullet_damage: int = 1
var score_multiplier: float = 1.0
# In degrees
var bullet_spread: float = DEFAULT_BULLET_SPREAD

var free_rerolls: int = 0
var free_upgrades: int = 0
var speed_time: float = 0.0
var multishots_left: int = 0
var health: int = max_health
var score: int = 0
var total_bits: int = 0
var patch_files: int = 0
var can_move: bool = true
var hurt_timer: float = 0.0

@export var explosion_scene: PackedScene
@onready var hud: HUD = $/root/Main.get_hud()

func reset() -> void:
	speed = 1.0
	max_health = DEFAULT_MAX_HEALTH
	shoot_cooldown = DEFAULT_SHOOT_COOLDOWN
	bullet_count = 1
	bullet_damage = 1
	score_multiplier = 1.0
	bullet_spread = DEFAULT_BULLET_SPREAD
	
	total_bits = 0
	health = max_health
	free_rerolls = 0
	free_upgrades = 0
	speed_time = 0.0
	multishots_left = 0
	score = 0
	patch_files = 0
	can_move = true

func _process(delta: float) -> void:
	hud.set_hp(health, max_health)
	hud.set_score(score)
	hud.set_patch_files(patch_files)
	hud.set_rerolls_and_upgrades(free_rerolls, free_upgrades)
	$Healthbar.update_bar(health, max_health)

	if !visible:
		velocity = Vector2.ZERO
		return

	modulate = lerp(Color.WHITE, Color.RED, hurt_timer)
	hurt_timer = max(hurt_timer - delta, 0.0)

	var level: Level = get_node_or_null("/root/Main/Level")
	if health <= 0:
		$/root/Main.stop_music()
		SfxManager.play_at("explosion", global_position, level)
		hud.set_hp(0, 0)
		hide()
		if level:
			var explosion: GPUParticles2D = explosion_scene.instantiate()
			explosion.global_position = global_position
			explosion.modulate = Color8(0xa6, 0xff, 0x00)
			explosion.scale *= 0.5
			explosion.connect("finished", hud.show_game_over)
			level.add_child(explosion)
		return

	if level and health > 0:
		for dx in range(-1, 1 + 1):
			for dy in range(-1, 1 + 1):
				var tile_pos = level.get_tile_pos(global_position + Vector2(dx, dy) * 3.0)
				if level.get_tile(tile_pos) == level.CORRUPTED:
					print("died to corrupted tile.")
					health = 0
					break	

	velocity = Vector2.ZERO
	
	# Movement
	if Input.is_action_pressed("up"):
		velocity.y -= 1.0
	if Input.is_action_pressed("down"):
		velocity.y += 1.0

	if Input.is_action_pressed("left"):
		velocity.x -= 1.0
	if Input.is_action_pressed("right"):
		velocity.x += 1.0

	if !can_move:
		velocity = Vector2.ZERO
	
	velocity = velocity.normalized() * speed * DEFAULT_SPEED
	if speed_time > 0.0:
		velocity *= 2.0
	speed_time = max(speed_time - delta, 0.0)

func add_score(amt: int) -> void:
	var multiplied: int = ceili(amt * score_multiplier)
	score += multiplied
	total_bits += multiplied

func _physics_process(_delta: float) -> void:
	move_and_slide()

func get_tile_position() -> Vector2i:
	var level: Level = get_node_or_null("/root/Main/Level")
	return Vector2i(
		floori(global_position.x / level.tile_sz.x),
		floori(global_position.y / level.tile_sz.y)
	)

func heal(amt: int) -> void:
	health = min(max_health, health + amt)

func clamp_value(id: String, min_val: float) -> void:
	set(id, max(get(id), min_val))

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	if health <= 0:
		return

	if area is Bullet:
		if area.is_in_group("player_bullet"):
			return
		$/root/Main.play_sfx("Hurt")
		health -= area.damage
		hurt_timer = 0.5
		area.explode()
	elif area.get_parent() is Bug and area.is_in_group("damage"):
		if area.get_parent().time_alive < 1.0:
			return
		if !area.get_parent().visible:
			return
		print("died to enemy.")
		health = 0
		area.get_parent().can_spawn_file = false
		area.get_parent().explode()
	health = max(health, 0)
