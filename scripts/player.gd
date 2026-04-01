extends CharacterBody2D

class_name Player

# Stats that can be upgraded
const DEFAULT_SPEED: float = 96.0
var speed: float = DEFAULT_SPEED
var max_health: int = 20

var shoot_cooldown: float = 0.5
var health: int = max_health

@export var explosion_scene: PackedScene
@onready var hud: HUD = $/root/Main.get_hud()

func _process(_delta: float) -> void:
	if !visible:
		velocity = Vector2.ZERO
		return

	if health <= 0:
		hud.set_hp(0, 0)
		hide()
		var level: Level = get_node_or_null("/root/Main/Level")
		if level:
			var explosion: GPUParticles2D = explosion_scene.instantiate()
			explosion.global_position = global_position
			explosion.modulate = Color8(0xa6, 0xff, 0x00)
			explosion.scale *= 0.5
			explosion.connect("finished", hud.show_game_over)
			level.add_child(explosion)
		return

	hud.set_hp(health, max_health)
	$Healthbar.update_bar(health, max_health)

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
	
	velocity = velocity.normalized() * speed

func _physics_process(_delta: float) -> void:
	move_and_slide()

func get_tile_position() -> Vector2i:
	var level: Level = get_node_or_null("/root/Main/Level")
	return Vector2i(
		floori(global_position.x / level.tile_sz.x),
		floori(global_position.y / level.tile_sz.y)
	)

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	if health <= 0:
		return

	if area is Bullet:
		health -= area.damage
		area.explode()
	elif area.get_parent() is Bug:
		health = 0
		area.get_parent().explode()
