class_name SfxManager

static var sfx_list: Dictionary = {
	"explosion" : preload("uid://d2ts34pp1f56f"),
	"pew" : preload("uid://dva5f6deahy2b"),
	"pop" : preload("uid://b8vtf65o7x62h"),
}

static func play_at(id: String, pos: Vector2, level: Level) -> void:
	if level == null:
		return
	if !(id in sfx_list):
		return
	var sfx: Sfx = sfx_list[id].instantiate()
	sfx.global_position = pos
	level.add_child(sfx)
