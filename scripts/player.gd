extends CharacterBody2D

const DEFAULT_SPEED: float = 96.0

var speed: float = DEFAULT_SPEED

func _process(delta: float) -> void:
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

func _physics_process(delta: float) -> void:
	move_and_slide()
