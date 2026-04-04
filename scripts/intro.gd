extends Control

@onready var labels: Array = $VBoxContainer.get_children()
var y_positions: Array = []
var index: int = 0
var current_text: String = ""
var current_text_index: int = 0
var add_char_timer: float = 0.0
const CHARS_PER_SEC: float = 128.0

func show_current_label() -> void:
	if index >= len(labels):
		return
	current_text = labels[index].text
	current_text_index = 0
	labels[index].show()
	labels[index].text = ""
	$Next.position = $VBoxContainer.position
	$Next.position += Vector2(0.0, y_positions[index])

func _ready() -> void:
	for label: Label in labels:
		label.hide()
	for label: Label in labels:
		if y_positions.is_empty():
			y_positions.push_back(label.size.y - $Next.size.y + 36.0)
		else:
			y_positions.push_back(y_positions[y_positions.size() - 1] + label.size.y + $VBoxContainer.get_theme_constant("separation"))
	show_current_label()

func _process(delta: float) -> void:
	if index >= len(labels):
		return

	add_char_timer += delta
	while add_char_timer > 0.0 and current_text_index < len(current_text):
		add_char_timer -= 1.0 / CHARS_PER_SEC
		labels[index].text += current_text[current_text_index]
		current_text_index += 1

func _on_skip_pressed() -> void:
	$/root/Main.play_sfx("Click")
	$/root/Main.save_highscore()
	queue_free()

func _on_next_pressed() -> void:
	$/root/Main.play_sfx("Click")
	labels[index].text = current_text
	index += 1
	add_char_timer = 0.0
	if index == len(labels) - 1:
		$Next.hide()
		$Skip.text = "Start!"	
	show_current_label()
