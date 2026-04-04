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

const LEVEL_DESCRIPTIONS: Dictionary = {
	"VIRUS" : "A virus has infected the program.\nAvoid the viruses while finding the patch files.",
	"SEGFAULT" : "There seems to be a bug corrupting memory.\nFind the patch files to fix it.",
	"MEMORY LEAK" : "Used memory is not being freed.\nAvoid or destroy the leaks that are spawning bugs.",
	"SECURITY BREACH" : "Hackers have stolen our data.\nYou need to fight and defeat them to get the patch files.",
	"C0RRUPT3D" : "The filesystem has been corrupted.",
}

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

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

func reset() -> void:
	current_level = 0
	time = 0.0
	if get_node_or_null("/root/Main/Level"):
		get_node_or_null("/root/Main/Level").queue_free()
	player.reset()
	player.show()
	player.modulate = Color.WHITE

func load_level(level_theme: String = "") -> void:
	var level: Level = level_scene.instantiate()
	# Immediately start corrupting the level if we have a SEGFAULT
	if level_theme == "SEGFAULT":
		level.corruption_timer = 2.0
	level.level_num = current_level
	level.theme = level_theme
	add_child(level)

func on_main_menu() -> bool:
	return $UI/MainMenu.visible

func show_main_menu() -> void:
	$UI/MainMenu.show()

func calculate_score() -> int:
	return player.score * 2 + player.total_bits + current_level * 32 + int(time)
