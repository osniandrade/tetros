extends CenterContainer

enum { STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE }

var gui
var state = STOPPED
var music_position = 0.0

const DISABLED = true
const ENABLED = false
var grid = []  # array of boolean values to indicating if a cell contains a tile
var cols  # number of columns in the grid
var shape: ShapeData  # stores the shape data for the current shape
var pos = 0  # stores the position of the shape within the grid

func _ready():
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)
	cols = gui.grid.get_columns()

func clear_grid():  # clear the grid when the game is started
	grid.clear()
	grid.resize(gui.grid.get_child_count())
	for i in grid.size():
		grid[i] = false
	gui.clear_all_cells()


func add_shape_to_the_grid():
	place_shape(pos, true, false, shape.color)

func remove_shape_from_grid():
	place_shape(pos, true)

func lock_shape_to_grid():
	place_shape(pos, false, true)

func place_shape(index, add_tiles = false, lock = false, color = Color(0)):
	# place the current shape into the grid
	# marks the cells within the shape to true and changes its color
	# also tests if the shapes can rotate and go to the new position
	# the function returns true if the shape can be placed
	# finally, it also locks the shape into the grid
	# index = position of the shape in the gui grid and also indicates occupied or unoccupied cells
	# add_tiles = decides to add or not add tiles to the grid
	# lock = locks the tile to the grid
	# color = tile color. if ommited, tile is transparent
	var ok = true  # return value
	var size = shape.coors.size()  # size of the shape
	var offset = shape.coors[0]  # distance of the edge of the shape from its origin
	var y = 0
	while y < size and ok:
		for x in size:
			if shape.grid[y][x]:
				var grid_pos = index + (y + offset) * cols + x + offset
				print(grid_pos)
				if lock:
					grid[grid_pos] = true
				elif grid_pos >= 0:
					var gx = index % cols + x + offset
					if gx < 0 or gx >= cols or grid_pos >= grid.size() or grid[grid_pos]:
						ok = !ok
						break
					if add_tiles:
						gui.grid.get_child(grid_pos).modulate = color
		y += 1
	return ok

func _button_pressed(button_name):
	match button_name:
		"NewGame":
			gui.set_button_states(DISABLED)
			_start_game()
			yield(get_tree().create_timer(3.0), "timeout")
			_game_over()
		"Pause":
			if state == PLAYING:
				gui.set_button_text("Pause", "Resume")
				state = PAUSED
				if _music_is_on():
					_music(PAUSE)
			else:
				gui.set_button_text("Pause", "Pause")
				state = PLAYING
				if _music_is_on():
					_music(PLAY)
		"Music":
			# copy gui.music value to data
			if state == PLAYING:
				if _music_is_on():
					print("Music changed. Level: %d" % gui.music)
					_music(PLAY)
				else:
					_music(STOP)
		"Sound":
			# copy gui.sound value to data
			if _sound_is_on():
				print("Sound changed. Level: %d" % gui.sound)
			else:
				print("Sound off.")
		"About":
			gui.set_button_state("About", DISABLED)

func _start_game():
	print("Game Playing.")
	state = PLAYING
	music_position = 0.0
	_music(PLAY)

func _game_over():
	gui.set_button_states(ENABLED)
	if _music_is_on():
		_music(STOP)
	state = STOPPED
	print("Game stopped.")

func _music(action):
	if action == PLAY:
		$MusicPlayer.volume_db = gui.music
		if !$MusicPlayer.is_playing():
			$MusicPlayer.play(music_position)
		print("Music started.")
	else:
		music_position = $MusicPlayer.get_playback_position()
		$MusicPlayer.stop()
		print("Music stopped.")

func _music_is_on():
	return gui.music > gui.min_vol

func _sound_is_on():
	return gui.sound > gui.min_vol
