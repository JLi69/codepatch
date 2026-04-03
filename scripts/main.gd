extends Node2D

class_name Main

@onready var camera: Camera2D = $/root/Main/Player/Camera2D
@onready var player: Player = $/root/Main/Player
var time: float = 0.0
var current_level: int = 0
@export var level_scene: PackedScene

const LEVEL_THEMES: Array[String] = [
	"VIRUS",
	"SEGFAULT",
	"MEMORY LEAK",
	"SECURITY BREACH",
	"C0RRUPT3D",
]

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	load_level()

func get_hud() -> HUD:
	return $UI/HUD

func _process(delta: float) -> void:
	if !camera.position_smoothing_enabled:
		camera.position_smoothing_enabled = true
	if player.visible:
		time += delta
		$UI/HUD.set_time(time)
		var level: Level = get_node_or_null("Level")
		if level:
			$UI/HUD.set_survive_timer(level.survive_timer, level.run_survive_timer)
			$UI/HUD.set_level(current_level, level.theme)
		else:
			$UI/HUD.set_survive_timer(0.0, false)

func load_level(level_theme: String = "") -> void:
	var level: Level = level_scene.instantiate()
	# Immediately start corrupting the level if we have a SEGFAULT
	if level_theme == "SEGFAULT":
		level.corruption_timer = 2.0
	level.level_num = current_level
	level.theme = level_theme
	add_child(level)
