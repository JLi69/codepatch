extends Node2D

class_name Level

var level_num: int = 0
@onready var player: Player = get_node_or_null("/root/Main/Player")
@onready var tile_sz: Vector2i = $TileMapLayer.tile_set.tile_size
var enemy_spawn_timer: float = 8.0
var enemy_spawn_interval: float = 30.0
var corruption_timer: float = 150.0
var corruption_interval: float = 12.0
var corruption_count: int = 0
var survive_timer: float = 60.0
var run_survive_timer: bool = false
var theme: String = ""
@export var explosion_scene: PackedScene
@export var patch_file_scene: PackedScene

var astar_grid: AStarGrid2D

static var enemy_scenes: Dictionary = {
	"bug" : preload("uid://dmtjl5wtign51"), 
	"red_bug" : preload("uid://bls7akohjqi2o"),
	"yellow_bug" : preload("uid://csl4bbvxy7owe"),
	"blue_bug" : preload("uid://dya7ogrxxfx3i")
}

var weights: Dictionary = {
	"bug" : 15.0,
	"red_bug" : 2.0,
	"blue_bug" : 1.0,
	"yellow_bug" : 1.0,
}
var total_weight: float = 0.0

const EMPTY: Vector2i = Vector2i(0, 0)
const WALL: Vector2i = Vector2i(1, 0)
const CORRUPTED: Vector2i = Vector2i(2, 0)
const ROOM_SIZE: int = 12

const ADJ: Array[Vector2i] = [ 
	Vector2i(1, 0), 
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

func get_level_size() -> int:
	match level_num:
		0, 1:
			return 5
		2, 3:
			return 6
		4, 5, 6:
			return 7
		7:
			return 8
		_:
			return 9

func spawn_enemy(id: String, tile_pos: Vector2i) -> bool:
	if !(id in enemy_scenes):
		return false

	if get_tile(tile_pos) != EMPTY:
		return false

	var enemy = enemy_scenes[id].instantiate()
	enemy.global_position = Vector2(tile_pos * tile_sz) + tile_sz / 2.0 
	$Enemies.add_child(enemy)
	return true

func _ready() -> void:
	var size: int = get_level_size()
	var spawn_room: Vector2i = Vector2i(randi_range(0, size - 1), randi_range(0, size - 1))
	# Set the player spawn position
	$PlayerSpawn.global_position.x = (float(spawn_room.x) * ROOM_SIZE + ROOM_SIZE / 2.0) * tile_sz.x
	$PlayerSpawn.global_position.y = (float(spawn_room.y) * ROOM_SIZE + ROOM_SIZE / 2.0) * tile_sz.y
	generate_level(size, size)
	print("Generated a %d x %d maze." % [ size, size ])
	if player:
		player.global_position = $PlayerSpawn.global_position
		var camera: Camera2D = $/root/Main/Player/Camera2D
		camera.position_smoothing_enabled = false

	var rooms: Array = []
	for rx in range(size):
		for ry in range(size):
			if Vector2i(rx, ry) == spawn_room:
				continue
			rooms.push_back(Vector2i(rx, ry))
	# Add the patch files
	var patch_rooms: Array = []
	for i in range(3):
		var index: int = randi() % len(rooms)
		while rooms[index] in patch_rooms:
			index += 1
			index %= len(rooms)
		patch_rooms.push_back(rooms[index])
	for room: Vector2i in patch_rooms:
		var tile_pos: Vector2i = room * ROOM_SIZE + Vector2i(randi_range(2, ROOM_SIZE - 2), randi_range(2, ROOM_SIZE - 2))
		var pos: Vector2 = Vector2(tile_pos * tile_sz) + tile_sz / 2.0
		var patch_file = patch_file_scene.instantiate()
		patch_file.global_position = pos
		add_child(patch_file)
	
	# Initialize the A* Grid
	var used_rect: Rect2i = $TileMapLayer.get_used_rect()
	astar_grid = AStarGrid2D.new()
	astar_grid.region = used_rect
	var tile_set: TileSet = $TileMapLayer.tile_set
	astar_grid.cell_size = tile_set.tile_size
	astar_grid.update()
	for cell in $TileMapLayer.get_used_cells():
		var tile_data: TileData = $TileMapLayer.get_cell_tile_data(cell)
		if tile_data == null:
			continue
		# Check if the tile has any polygons representing its collision, 
		# if it does, then mark it as a solid tile
		if tile_data.get_collision_polygons_count(0) > 0:
			astar_grid.set_point_solid(cell)
	
	for id in weights:
		total_weight += weights[id]

func set_tile(pos: Vector2i, type: Vector2i) -> void:
	$TileMapLayer.set_cell(pos, 0, type)

func get_tile(pos: Vector2i) -> Vector2i:
	return $TileMapLayer.get_cell_atlas_coords(pos)

func get_tile_pos(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / tile_sz.x), floori(pos.y / tile_sz.y))

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

func spawn_enemies() -> void:
	var enemy_count: int = randi_range(2, 5)
	for i in range(enemy_count):
		var attempts_left: int = 3
		while attempts_left > 0:
			var dist: float = randf_range(8.0, 24.0)
			var angle: float = randf_range(0.0, 2.0 * PI)
			var rand_pos: Vector2i = Vector2i(
				floori(dist * cos(angle)),
				floori(dist * sin(angle)),
			)
			var id: String = ""
			var randval: float = randf_range(0.0, total_weight)
			for enemy_id in weights:
				randval -= weights[enemy_id]
				if randval <= 0.0:
					id = enemy_id
					break
			if spawn_enemy(id, rand_pos + get_tile_pos(player.global_position)):
				break
			attempts_left -= 1

func corrupt_tiles(count: int) -> void:
	for i in range(count):
		var dist: float = randf_range(7.0, 24.0)
		var angle: float = randf_range(0.0, 2.0 * PI)
		var rand_pos: Vector2i = Vector2i(
			floori(dist * cos(angle)),
			floori(dist * sin(angle)),
		)
		var tile_pos: Vector2i = rand_pos + get_tile_pos(player.global_position)
		if get_tile(tile_pos) != EMPTY:
			continue
		set_tile(tile_pos, CORRUPTED)
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		explosion.global_position = Vector2(tile_pos * tile_sz) + tile_sz / 2.0
		explosion.scale *= 0.4
		add_child(explosion)

func _process(delta: float) -> void:
	if survive_timer <= -0.5 and player.health > 0:
		modulate.r -= delta
		modulate.g = modulate.r
		modulate.b = modulate.r
		player.modulate = modulate
		if modulate.r <= 0.0:
			if level_num % 8 == 7:
				player.add_score(1024)
			player.hide()
			var hud: HUD = $/root/Main/UI/HUD
			hud.activate_store()
			queue_free()
		return

	if player.health > 0 and run_survive_timer:
		survive_timer -= delta
		if survive_timer <= 0.0:
			player.can_move = false
			if get_node_or_null("Enemies"):
				$Enemies.process_mode = Node.PROCESS_MODE_DISABLED

	# Spawn enemies
	if player.health > 0:
		enemy_spawn_timer -= delta
	if enemy_spawn_timer < 0.0:
		spawn_enemies()
		enemy_spawn_timer = enemy_spawn_interval * randf_range(1.0, 1.25)
		if player.patch_files < 3:
			enemy_spawn_interval = max(enemy_spawn_interval * 0.9, 15.0)
	
	corruption_timer -= delta
	if corruption_timer < 0.0:
		corruption_timer = corruption_interval * randf_range(1.0, 1.25)
		corrupt_tiles(randi_range(4 + corruption_count, 8 + corruption_count))
		if randi() % 3 == 0:
			corruption_count += 1
		corruption_count = min(corruption_count, 16)
		corruption_interval = max(corruption_interval * 0.9, 5.0)
