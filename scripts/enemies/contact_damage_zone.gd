extends Area2D

var can_attack_player: bool = false
@export var damage_cooldown_time: float = 0.25
@export var damage: int = 1
@onready var player: Player = $/root/Main/Player

func _ready() -> void:
	$Timer.wait_time = damage_cooldown_time

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		can_attack_player = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		can_attack_player = true

func _on_timer_timeout() -> void:
	if can_attack_player:
		player.damage(damage)
