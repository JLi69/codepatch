extends Area2D

class_name FileItem

@export var explosion_scene: PackedScene

var pulse_time: float = 0.0
@onready var glow_offset: float = randf_range(0.0, 2.0 * PI)

const POSSIBLE_EFFECTS: Array[String] = [
	"heal",
	"heal",
	"heal",
	"heal",
	"speed",
	"speed",
	"bits",
	"bits",
	"bits",
	"bullet",
	"reroll",
	"upgrade",
]

var id: String = ""

func _ready() -> void:
	if id.is_empty():
		id = POSSIBLE_EFFECTS[randi() % len(POSSIBLE_EFFECTS)]
	# Set the color
	match id:
		"heal":
			modulate = Color.RED
		"speed":
			modulate = Color.YELLOW
		"bits":
			modulate = Color.ORANGE
		"bullet":
			modulate = Color8(0xa6, 0xff, 0x00)
		"reroll":
			modulate = Color.GREEN
		"upgrade":
			modulate = Color.CYAN

func _process(delta: float) -> void:
	pulse_time += delta
	var size = 1.0 + sin(pulse_time * PI + glow_offset) * 0.25
	$Glow.scale = Vector2(size, size)

	size = 1.0 + sin(pulse_time * PI * 0.9 + glow_offset) * 0.125
	$Sprite2D.scale = Vector2(size, size)

func apply_effect(player: Player) -> void:
	match id:
		"heal":
			player.heal(randi_range(int(player.max_health / 4.0), int(player.max_health / 2.0)))
		"speed":
			player.speed_time += 15.0
		"bits":
			player.score += randi_range(32, 512)	
		"bullet":
			player.multishots_left += 15
		"reroll":
			player.free_rerolls += 1
		"upgrade":
			player.free_upgrades += 1

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().health <= 0:
			return

		$/root/Main.play_sfx("Pickup")
		queue_free()
		var player: Player = area.get_parent()
		apply_effect(player)
		
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.scale *= 0.2
		explosion.global_position = global_position
		explosion.modulate = modulate
		explosion.modulate.a = 0.5
		var level: Level = get_node_or_null("/root/Main/Level")
		if level:
			level.add_child(explosion)
