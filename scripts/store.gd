extends Control

@onready var player: Player = $/root/Main/Player
@onready var main: Main = $/root/Main

const HEAL_COST: int = 256
const DEFAULT_REROLL_COST: int = 512
var reroll_cost: int = 512
var level_theme: String = ""

func setup_stats() -> void:
	$Stats.text = "<STATS>\n\n"
	$Stats.text += "MAX HP: %d\n" % player.max_health
	$Stats.text += "SPEED: x%.3f\n" % (player.speed / player.DEFAULT_SPEED)
	$Stats.text += "SHOOT DELAY: %dms\n" % int(player.shoot_cooldown * 1000.0)
	$Stats.text += "BULLET COUNT: %d\n" % player.bullet_count
	$Stats.text += "BULLET SPREAD: %ddeg\n" % roundi(rad_to_deg(player.bullet_spread))
	$Stats.text += "BULLET DAMAGE: %d\n" % player.bullet_damage
	$Stats.text += "BIT MULT: x%.3f\n" % player.score_multiplier

func setup_buy_heal() -> void:
	$Buttons/BuyHeal.disabled = player.score < HEAL_COST or player.health >= player.max_health

func setup_reroll() -> void:
	$Buttons/Reroll.disabled = player.score < reroll_cost

func setup_next_level() -> void:
	$NextLevel.text = """> NEXT LEVEL
"%s"
(+4 MAX HP, HEAL 16 HP)
""" % level_theme

func activate() -> void:
	show()
	modulate = Color.BLACK

	setup_stats()
	setup_buy_heal()
	setup_reroll()
	level_theme = Main.LEVEL_THEMES[randi() % len(Main.LEVEL_THEMES)]
	setup_next_level()

	if main.current_level == 7:
		$WinMsg.show()
	else:
		$WinMsg.hide()

func _process(delta: float) -> void:
	modulate.r = min(modulate.r + delta, 1.0)
	modulate.g = modulate.r
	modulate.b = modulate.r

func _on_buy_heal_pressed() -> void:
	if player.score < HEAL_COST or player.health >= player.max_health:
		return
	player.score -= HEAL_COST
	player.heal(16)
	setup_buy_heal()

func _on_next_level_pressed() -> void:
	player.max_health += 4
	player.health += 4
	player.heal(16)
	player.can_move = true
	player.modulate = Color.WHITE
	player.show()
	player.patch_files = 0
	main.current_level += 1
	main.load_level(level_theme)
	hide()
