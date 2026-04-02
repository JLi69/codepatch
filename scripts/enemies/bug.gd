extends CharacterBody2D

class_name Bug

@onready var player: Player = $/root/Main/Player
@onready var level: Level = get_node_or_null("/root/Main/Level")
@export var speed: float = 60.0
@export var min_chase_distance: float = 10.0
@export var max_chase_distance: float = 320.0
@export var max_health: int = 4
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var bullet_damage: int = 1
@export var score_value: int = 10
@export var file_scene: PackedScene
@export var file_drop: String = ""
@export var drop_file_probability: float = 1.0 / 8.0
# How long it takes for the enemy to shoot a bullet (in seconds)
@export var bullet_cooldown: float = 1.0
@onready var shoot_timer: float = bullet_cooldown
@onready var health = max_health
var path: PackedVector2Array = []
var current_path_index: int = 0
const ARRIVE_DISTANCE: float = 8.0
var target_tile_pos: Vector2i

var pause_timer: float = 0.5
var pause_interval: float = 1.0

const UPDATE_PATH_INTERVAL: float = 0.25
var update_path_timer: float = UPDATE_PATH_INTERVAL

func _ready() -> void:
	$Healthbar.healthbar_color = $AnimatedSprite2D.modulate
	$Healthbar.hide()
	rotation = randf_range(0.0, 2.0 * PI)
	speed *= randf_range(0.9, 1.25)

	# Explosion effect when the enemy first spawns in
	if level:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.scale *= 0.4
		explosion.modulate = $AnimatedSprite2D.modulate
		level.add_child(explosion)

# Returns the tile coordinates that this enemy is currently occupying
func get_tile_pos() -> Vector2i:
	return Vector2i(
		floor(global_position.x / level.tile_sz.x),
		floor(global_position.y / level.tile_sz.y)
	)

func update_path() -> void:
	target_tile_pos = player.get_tile_position()
	path = level.astar_grid.get_point_path(get_tile_pos(), player.get_tile_position())
	var offsets: Array[Vector2] = []
	for i in range(len(path)):
		path[i].x += level.tile_sz.x / 2.0
		path[i].y += level.tile_sz.y / 2.0
		if i == 0:
			offsets.push_back(Vector2(0.0, 0.0))
			continue
		var prev: Vector2 = path[i - 1]
		var offset: Vector2 = Vector2(path[i].x - prev.x, path[i].y - prev.y) * 0.6
		if offset.y < 0.0:
			offset.y += $CollisionShape2D.shape.get_rect().size.y / 2.0
		offsets.push_back(offset)
	for i in range(len(offsets)):
		path[i] += offsets[i]
	current_path_index = 0

func can_chase_player() -> bool:
	if player.health <= 0:
		return false
	var player_pos = player.global_position
	var player_dist = (player_pos - global_position).length()
	return player_dist <= max_chase_distance and player_dist >= min_chase_distance

func calculate_velocity() -> Vector2:
	if pause_timer > 0.0:
		return Vector2.ZERO

	var vel: Vector2 = Vector2.ZERO

	if !can_chase_player():
		return Vector2.ZERO

	if level == null:
		return Vector2.ZERO	

	if current_path_index >= len(path):
		return Vector2.ZERO	

	var dist: float = (path[current_path_index] - global_position).length()
	if dist < ARRIVE_DISTANCE or current_path_index == 0:
		current_path_index += 1
	if current_path_index >= len(path):
		return Vector2.ZERO

	var next_pos: Vector2 = path[current_path_index]
	vel = (next_pos - global_position).normalized() * speed

	return vel

# Shoots a bullet in the direction of the player, it can also have an offset
# from being directly shot at the player.
func shoot_bullet(offset: float = 0.0) -> void:
	if bullet_scene == null:
		return
	var spawn_point: Node2D = get_node_or_null("BulletSpawnPoint")
	if spawn_point == null:
		return
	var bullet: Bullet = bullet_scene.instantiate()
	var angle = (player.position - global_position).angle() + offset
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = spawn_point.global_position + dir * 4.0
	bullet.dir = dir
	bullet.speed += speed
	bullet.modulate = $AnimatedSprite2D.modulate
	bullet.damage = bullet_damage
	level.add_child(bullet)

# Shoots bullets at the player, this function should be overridden if an enemy
# has a different shooting pattern
func shoot() -> void:
	shoot_bullet()

func in_shooting_range() -> bool:
	return can_chase_player()

func update_shooting(delta: float) -> void:
	if bullet_cooldown < 0.0:
		return

	shoot_timer -= delta

	if player.health <= 0:
		return

	if shoot_timer >= 0.0:
		return

	if !in_shooting_range():
		return

	if len(path) - 1 - current_path_index >= 15:
		return
	
	shoot()
	shoot_timer = bullet_cooldown

# Returns true if the path was updated
func handle_path_update(delta: float) -> bool:
	if player.get_tile_position() != target_tile_pos:
		update_path_timer -= delta
	else:
		update_path_timer = UPDATE_PATH_INTERVAL
	if update_path_timer <= 0.0:
		update_path_timer = UPDATE_PATH_INTERVAL
		update_path()
		return true
	return false

func explode() -> void:
	queue_free()
	if player.health > 0:
		player.add_score(score_value)
	var explosion: GPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale *= 0.4
	explosion.modulate = $AnimatedSprite2D.modulate
	level.add_child(explosion)

	if randf() < drop_file_probability:
		var file: FileItem = file_scene.instantiate()
		file.global_position = global_position
		file.id = file_drop
		if level:
			level.add_child(file)

func _process(delta: float) -> void:
	$Healthbar.update_bar(health, max_health)
	if health <= 0:
		explode()
		return
	
	if player.health <= 0:
		return
	
	handle_path_update(delta)
	update_shooting(delta)

	if velocity.length() > 0.0 and pause_timer <= 0.0:
		var dir: Vector2 = velocity.normalized()
		var diff: float = 1.25 * PI * delta
		var counterclockwise: Vector2 = Vector2(
			cos(rotation - PI / 2.0 + diff), 
			sin(rotation - PI / 2.0 + diff)
		)
		var clockwise: Vector2 = Vector2(
			cos(rotation - PI / 2.0 - diff), 
			sin(rotation - PI / 2.0 - diff)
		)
		if counterclockwise.dot(dir) >= clockwise.dot(dir) and counterclockwise.dot(dir) < 0.996:
			rotation += diff
		elif counterclockwise.dot(dir) < clockwise.dot(dir) and clockwise.dot(dir) < 0.996:
			rotation -= diff
		else:
			var target_rotation: float = velocity.angle() + PI / 2.0
			rotation = target_rotation

	if pause_interval > 0.0:
		pause_interval -= delta
		if pause_interval <= 0.0:
			pause_timer = randf_range(0.25, 0.5)
	
	if pause_timer > 0.0:
		pause_timer -= delta
		if pause_timer <= 0.0:
			pause_interval = randf_range(3.0, 5.0)

func _physics_process(_delta: float) -> void:
	velocity = calculate_velocity()
	move_and_slide()

func damage(amt: int) -> void:
	health -= amt
	health = max(health, 0)

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body.is_in_group("player_bullet") and body is Bullet:
		body.explode()
		damage(body.damage)
