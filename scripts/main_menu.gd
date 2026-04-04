extends Control

@onready var main: Main = $/root/Main
@export var explosion_scene: PackedScene
@onready var viewrect: Rect2 = get_viewport().get_visible_rect()
var spawn_timer: float = 1.0
var time: float = 0.0

func _ready() -> void:
	$Bug.hide()
	if OS.get_name() == "Web":
		$VBoxContainer/Quit.hide()
	$Title.position = Vector2(viewrect.size.x / 2.0, 140.0)
	$TitleBackground.position = $Title.position + Vector2(0.0, 3.0)

func _process(delta: float) -> void:
	if visible:
		get_tree().paused = true
	else:
		return

	$VBoxContainer/HighScore.text = "High Score: %d" % $/root/Main.high_score

	spawn_timer -= delta
	if spawn_timer < 0.0:
		spawn_timer = randf_range(3.0, 6.0)
		for i in range(randi_range(1, 4)):
			var explosion: GPUParticles2D = explosion_scene.instantiate()
			explosion.global_position = viewrect.size * Vector2(randf(), randf())
			var bug: AnimatedSprite2D = $Bug.duplicate()
			bug.global_position = explosion.global_position
			bug.rotation = randf_range(0.0, 2.0 * PI)
			bug.show()
			add_child(bug)
			add_child(explosion)
	
	$Title.position.y = 140.0 + sin(time) * 6.0
	time += delta

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_new_run_pressed() -> void:
	get_tree().paused = false
	main.reset()
	main.load_level()
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _on_credits_pressed() -> void:
	$Credits.show()

func _on_settings_pressed() -> void:
	$/root/Main.show_settings()

