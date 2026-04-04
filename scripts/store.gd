extends Control

class Upgrade:
	var cost: int = 0
	# Double = upgrade one stat, downgrade another
	const UPGRADE_TYPE_LIST: Array[String] = [ "add", "mult", "double" ]
	var upgrade_type: String = ""
	const STAT_LIST: Array[String] = [
		"max_health",
		"speed",
		"bullet_count",
		"bullet_spread",
		"bullet_damage",
		"shoot_cooldown",
		"score_multiplier",
	]
	var value: float = 0.0
	var upgrade_stat: String = ""
	var downgrade_value: float = 0.0
	var downgrade_stat: String = ""

	const UPGRADE_VALUES_ADD: Dictionary = {
		"max_health" : [ 6.0, 8.0, 10.0, 12.0 ],
		"speed" : [ 0.05, 0.1, 0.15, 0.15, 0.25, 0.25, 0.3 ],
		"bullet_count" : [ 1.0, 1.0, 2.0 ],
		"bullet_spread": [ 8.0, 6.0, 5.0, -5.0, -6.0, -8.0 ],
		"bullet_damage" : [ 1.0, 1.0, 1.0, 2.0 ],
		"shoot_cooldown" : [ -0.025, -0.05, -0.05, -0.075, -0.1 ],
		"score_multiplier" : [ 0.1, 0.1, 0.15, 0.15, 0.2, 0.2, 0.25, 0.4, 0.5 ],
	}

	const UPGRADE_VALUES_MULT: Dictionary = {
		"max_health" : [ 1.1, 1.15, 1.2, 1.25 ],
		"speed" : [ 1.05, 1.1, 1.1, 1.15, 1.2 ],
		"bullet_count" : [ 1.1, 1.25, 1.5 ],
		"bullet_spread": [ 0.95, 0.9, 0.9, 0.85, 0.8 ],
		"bullet_damage" : [ 1.1, 1.25, 1.5  ],
		"shoot_cooldown" : [ 0.95, 0.95, 0.9, 0.9, 0.85, 0.8, 0.75 ],
		"score_multiplier" : [ 1.1, 1.2, 1.3, 1.4, 1.5 ],
	}

	const UPGRADE_NAME: Dictionary = {
		"max_health" : "MAX HP",
		"speed" : "SPEED",
		"bullet_count" : "COUNT",
		"bullet_spread" : "SPREAD",
		"bullet_damage" : "DAMAGE" ,
		"shoot_cooldown" : "COOLDOWN",
		"score_multiplier" : "BIT MULT",
	}

	const MIN_VALUES: Dictionary = {
		"max_health" : 1,
		"speed" : 0.01,
		"bullet_count" : 0,
		"bullet_damage" : 0,
		"bullet_spread" : 0.001,
		"shoot_cooldown" : 0.001,
		"score_multiplier" : 0.0,
	}

	static var format_str: Dictionary = {
		"max_health" : func(v: float) -> String: return "%d" % int(v),
		"speed" : func(v: float) -> String: return "%.2f" % v,
		"bullet_count" : func(v: float) -> String: return "%d" % int(v),
		"bullet_spread" : func(v: float) -> String: return "%ddeg" % int(v),
		"bullet_damage" : func(v: float) -> String: return "%d" % int(v),
		"shoot_cooldown" : func(v: float) -> String: return "%dms" % int(v * 1000.0),
		"score_multiplier" : func(v: float) -> String: return "%.2f" % v,
	}

	func _init() -> void:
		upgrade_type = UPGRADE_TYPE_LIST[randi() % len(UPGRADE_TYPE_LIST)]
		var index: int
		match upgrade_type:
			"add":
				upgrade_stat = STAT_LIST[randi() % len(STAT_LIST)]
				cost = randi_range(250, 500)
				# Get the stat value change of the upgrade
				index = randi_range(0, len(UPGRADE_VALUES_ADD[upgrade_stat]) - 1)
				value = UPGRADE_VALUES_ADD[upgrade_stat][index]
			"mult":
				upgrade_stat = STAT_LIST[randi() % len(STAT_LIST)]
				cost = randi_range(300, 800)
				# Get the stat value of the upgrade
				index = randi_range(0, len(UPGRADE_VALUES_MULT[upgrade_stat]) - 1)
				value = UPGRADE_VALUES_MULT[upgrade_stat][index]
			"double":
				index = randi() % len(STAT_LIST)
				upgrade_stat = STAT_LIST[index]
				downgrade_stat = STAT_LIST[randi() % len(STAT_LIST)]
				if downgrade_stat == upgrade_stat:
					downgrade_stat = STAT_LIST[(index + 1) % len(STAT_LIST)]
				cost = randi_range(400, 800)
				# Get the stat value of the upgrade
				index = randi_range(0, len(UPGRADE_VALUES_ADD[upgrade_stat]) - 1)
				value = UPGRADE_VALUES_ADD[upgrade_stat][index] * 2.0
				index = randi_range(0, len(UPGRADE_VALUES_ADD[downgrade_stat]) - 1)
				downgrade_value = -UPGRADE_VALUES_ADD[downgrade_stat][index]

	func apply(player: Player) -> void:
		match upgrade_type:
			"add":
				if player.get(upgrade_stat) is int:
					if upgrade_stat == "max_health":
						player.health += int(value)
					player.set(upgrade_stat, player.get(upgrade_stat) + int(value))
				elif player.get(upgrade_stat) is float:
					player.set(upgrade_stat, player.get(upgrade_stat) + value)
				player.clamp_value(upgrade_stat, MIN_VALUES[upgrade_stat])
			"mult":
				if player.get(upgrade_stat) is int:
					if upgrade_stat == "max_health":
						var next_val: int = ceili(player.max_health * value)
						player.health += next_val - player.max_health
					player.set(upgrade_stat, ceili(player.get(upgrade_stat) * value))
				elif player.get(upgrade_stat) is float:
					player.set(upgrade_stat, player.get(upgrade_stat) * value)
				player.clamp_value(upgrade_stat, MIN_VALUES[upgrade_stat])
			"double":
				if player.get(upgrade_stat) is int:
					if upgrade_stat == "max_health":
						player.health += int(value)
					player.set(upgrade_stat, player.get(upgrade_stat) + int(value))
				elif player.get(upgrade_stat) is float:
					player.set(upgrade_stat, player.get(upgrade_stat) + value)
				player.clamp_value(upgrade_stat, MIN_VALUES[upgrade_stat])

				if player.get(downgrade_stat) is int:
					if downgrade_stat == "max_health":
						player.health += int(downgrade_value)
					player.set(downgrade_stat, player.get(downgrade_stat) + int(downgrade_value))
				elif player.get(downgrade_stat) is float:
					player.set(downgrade_stat, player.get(downgrade_stat) + downgrade_value)
				player.clamp_value(downgrade_stat, MIN_VALUES[downgrade_stat])
		player.health = max(player.health, 1)

	func get_string() -> String:
		var msg: String = ""
		
		msg += "%s: " % UPGRADE_NAME[upgrade_stat]
		
		match upgrade_type:
			"add":
				if value > 0.0:
					msg += "+" + format_str[upgrade_stat].call(value)
				else:
					msg += format_str[upgrade_stat].call(value)	
			"mult":
				msg += "x%.2f" % value
			"double":
				if value > 0.0:
					msg += "+" + format_str[upgrade_stat].call(value)
				else:
					msg += format_str[upgrade_stat].call(value)	
				msg += ", %s: " % UPGRADE_NAME[downgrade_stat]
				if downgrade_value > 0.0:
					msg += "+" + format_str[downgrade_stat].call(downgrade_value)
				else:
					msg += format_str[downgrade_stat].call(downgrade_value)	

		return msg

@onready var player: Player = $/root/Main/Player
@onready var main: Main = $/root/Main

const HEAL_COST: int = 256
const DEFAULT_REROLL_COST: int = 512
var reroll_cost: int = 512
var level_theme: String = ""

@onready var upgrade_buttons: Array = [
	$Buttons/Upgrade1,
	$Buttons/Upgrade2,
	$Buttons/Upgrade3,
]

var upgrades: Array[Upgrade] = []

func apply_upgrade(index: int) -> void:
	if index < 0 or index >= len(upgrades):
		return
	if upgrades[index] == null:
		return
	if player.score < upgrades[index].cost and player.free_upgrades <= 0:
		return
	$/root/Main.play_sfx("Click")
	if player.free_upgrades > 0:
		player.free_upgrades -= 1
	else:
		player.score -= upgrades[index].cost
	upgrade_buttons[index].hide()
	upgrades[index].apply(player)
	setup_stats()
	reload_buttons()

func _ready() -> void:
	for i in range(len(upgrade_buttons)):
		var upgrade_button: Button = upgrade_buttons[i]
		upgrades.push_back(null)
		upgrade_button.connect("pressed", func() -> void: apply_upgrade(i))

func setup_stats() -> void:
	$Stats.text = "<STATS>\n\n"
	$Stats.text += "MAX HP: %d\n" % player.max_health
	$Stats.text += "SPEED: x%.3f\n" % player.speed
	$Stats.text += "COOLDOWN: %dms\n" % int(player.shoot_cooldown * 1000.0)
	$Stats.text += "COUNT: %d\n" % player.bullet_count
	$Stats.text += "SPREAD: %ddeg\n" % roundi(player.bullet_spread)
	$Stats.text += "DAMAGE: %d\n" % player.bullet_damage
	$Stats.text += "BIT MULT: x%.3f\n" % player.score_multiplier

func setup_buy_heal() -> void:
	$Buttons/BuyHeal.disabled = player.score < HEAL_COST or player.health >= player.max_health

func setup_reroll() -> void:
	$Buttons/Reroll.disabled = player.score < reroll_cost and player.free_rerolls <= 0
	if player.free_rerolls > 0:
		$Buttons/Reroll.text = "REROLL (-1 reroll)"
	else:
		$Buttons/Reroll.text = "REROLL (%d bits)" % reroll_cost

func reload_upgrade_button_text() -> void:
	for i in range(len(upgrade_buttons)):
		upgrade_buttons[i].text = upgrades[i].get_string()
		if player.free_upgrades > 0:
			upgrade_buttons[i].text += "\n(-1 upgrade)"	
		else:
			upgrade_buttons[i].text += "\n(%d bits)" % upgrades[i].cost	
		upgrade_buttons[i].disabled = upgrades[i].cost > player.score and player.free_upgrades <= 0

func reload_buttons() -> void:
	setup_buy_heal()
	setup_reroll()
	reload_upgrade_button_text()

func setup_upgrades() -> void:
	for i in range(len(upgrades)):
		upgrades[i] = Upgrade.new()
	for upgrade_button in upgrade_buttons:
		upgrade_button.show()
	reload_buttons()

func setup_next_level() -> void:
	if level_theme.is_empty():
		$NextLevel.text = """> NEXT LEVEL
(+4 MAX HP, HEAL 16 HP)
"""
		$Description.text = ""
		return

	$NextLevel.text = """> NEXT LEVEL
"%s"
(+4 MAX HP, HEAL 16 HP)
""" % level_theme
	$Description.text = Main.LEVEL_DESCRIPTIONS[level_theme]

func activate() -> void:
	show()
	modulate = Color.BLACK

	setup_stats()
	setup_buy_heal()
	setup_reroll()
	setup_upgrades()
	if (main.current_level + 1) % 2 == 1:
		level_theme = Main.LEVEL_THEMES[randi() % len(Main.LEVEL_THEMES)]
	else:
		level_theme = ""
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
	$/root/Main.play_sfx("Click")
	player.score -= HEAL_COST
	player.heal(16)
	reload_buttons()

func _on_next_level_pressed() -> void:
	$/root/Main.play_sfx("Click")
	player.max_health += 4
	player.health += 4
	player.heal(16)
	player.can_move = true
	player.modulate = Color.WHITE
	player.show()
	player.patch_files = 0
	main.current_level += 1
	main.load_level(level_theme)
	reroll_cost = DEFAULT_REROLL_COST
	hide()

func _on_reroll_pressed() -> void:
	if player.score < reroll_cost and player.free_rerolls <= 0:
		return
	$/root/Main.play_sfx("Click")
	if player.free_rerolls > 0:
		player.free_rerolls -= 1
	else:
		player.score -= reroll_cost
		reroll_cost = floori(reroll_cost * 1.25)
	setup_upgrades()
	reload_buttons()
