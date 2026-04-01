extends Node2D

@onready var camera: Camera2D = $/root/Main/Player/Camera2D
@onready var player: Player = $/root/Main/Player

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func get_hud() -> HUD:
	return $UI/HUD

func _process(delta: float) -> void:
	if !camera.position_smoothing_enabled:
		camera.position_smoothing_enabled = true
