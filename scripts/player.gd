extends CharacterBody2D

class_name Player

# Stats that can be upgraded
const DEFAULT_SPEED: float = 96.0
var speed: float = DEFAULT_SPEED
var max_health: int = 20

var shoot_cooldown: float = 0.5
var health: int = max_health

func _process(_delta: float) -> void:
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
