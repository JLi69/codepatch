extends Node2D

class_name Level

var level_num: int = 0
@onready var player: Player = get_node_or_null("/root/Main/Player")
@onready var tile_sz: Vector2i = $TileMapLayer.tile_set.tile_size

const EMPTY: Vector2i = Vector2i(0, 0)
const WALL: Vector2i = Vector2i(1, 0)
const ROOM_SIZE: int = 12

const ADJ: Array[Vector2i] = [ 
	Vector2i(1, 0), 
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

func get_level_size() -> int:
	match level_num:
		1:
			return 5
		2, 3:
			return 7
		4, 5, 6:
			return 9
		7:
			return 11
		_:
			return 12

func _ready() -> void:
	var size: int = get_level_size()
	var spawn_room: Vector2i = Vector2i(randi_range(0, size - 1), randi_range(0, size - 1))
	# Set the player spawn position
	$PlayerSpawn.global_position.x = (float(spawn_room.x) * ROOM_SIZE + ROOM_SIZE / 2.0) * tile_sz.x
	$PlayerSpawn.global_position.y = (float(spawn_room.y) * ROOM_SIZE + ROOM_SIZE / 2.0) * tile_sz.y
	generate_level(size, size)
	if player:
		player.global_position = $PlayerSpawn.global_position	

func set_tile(pos: Vector2i, type: Vector2i) -> void:
	$TileMapLayer.set_cell(pos, 0, type)

func get_tile(pos: Vector2i) -> Vector2i:
	return $TileMapLayer.get_cell_atlas_coords(pos)

func clear_wall(current: Vector2i, next: Vector2i) -> void:
	var room_pos: Vector2i = current * ROOM_SIZE
	if next.x < current.x:
		for x in range(-1, 1):
			for y in range(1, ROOM_SIZE - 1):
				var tile_pos: Vector2i = Vector2i(x, y) + room_pos
				set_tile(tile_pos, EMPTY)
	elif next.x > current.x:
		for x in range(ROOM_SIZE - 1, ROOM_SIZE + 1):
			for y in range(1, ROOM_SIZE - 1):
				var tile_pos: Vector2i = Vector2i(x, y) + room_pos
				set_tile(tile_pos, EMPTY)
	elif next.y < current.y:
		for x in range(1, ROOM_SIZE - 1):
			for y in range(-1, 1):
				var tile_pos: Vector2i = Vector2i(x, y) + room_pos
				set_tile(tile_pos, EMPTY)
	elif next.y > current.y:
		for x in range(1, ROOM_SIZE - 1):
			for y in range(ROOM_SIZE - 1, ROOM_SIZE + 1):
				var tile_pos: Vector2i = Vector2i(x, y) + room_pos
				set_tile(tile_pos, EMPTY)

func gen_maze(width: int, height: int) -> void:
	var visited = {}
	var stack = []
	stack.push_back(Vector2i(0, 0))
	while !stack.is_empty():
		var top: Vector2i = stack.back()
		visited[top] = true
		# Check for neighboring tiles to move to
		var possible = []
		for adj in ADJ:
			var pos = top + adj
			if pos in visited:
				continue
			if pos.x < 0 or pos.y < 0 or pos.x >= width or pos.y >= height:
				continue
			possible.push_back(pos)
		# If we do not have any possible places to go, ignore this tile
		if possible.is_empty():
			stack.pop_back()
			continue
		var index: int = randi_range(0, possible.size() - 1)
		var next: Vector2i = possible[index]
		clear_wall(top, next)
		stack.push_back(next)

func generate_level(width: int, height: int) -> void:
	# Generate the outlines of the rooms
	for rx in range(0, width):
		for ry in range(0, height):
			for x in range(0, ROOM_SIZE):
				for y in range(0, ROOM_SIZE):
					var tile_pos: Vector2i = Vector2i(rx * ROOM_SIZE + x, ry * ROOM_SIZE + y)
					if x == 0 or y == 0 or x == ROOM_SIZE - 1 or y == ROOM_SIZE - 1:
						set_tile(tile_pos, WALL)
					else:
						set_tile(tile_pos, EMPTY)
	
	gen_maze(width, height)
	
	# Get the bounding rectangle of the level
	var cells: Array = $TileMapLayer.get_used_cells()
	if cells.is_empty():
		return
	var top_left: Vector2i = cells[0]
	var bot_right: Vector2i = cells[0]
	for pos in cells:
		top_left.x = min(top_left.x, pos.x)
		top_left.y = min(top_left.y, pos.y)

		bot_right.x = max(bot_right.x, pos.x)
		bot_right.y = max(bot_right.y, pos.y)
	
	# Set the outline around the bounding rectangle
	var outline: Array = []
	for x in range(top_left.x - 1, bot_right.x + 1 + 1):
		for y in range(top_left.y - 1, bot_right.y + 1 + 1):
			var tile_pos: Vector2i = Vector2i(x, y)
			if get_tile(tile_pos) != Vector2i(-1, -1):
				continue
			for dx in range(-1, 1 + 1):
				for dy in range(-1, 1 + 1):
					if dx == 0 and dy == 0:
						continue
					var diff: Vector2i = Vector2i(dx, dy)
					var adj_pos: Vector2i = tile_pos + diff
					if get_tile(adj_pos) == WALL:
						outline.push_back(tile_pos)
						break	
	for tile_pos in outline:
		set_tile(tile_pos, WALL)
