extends CenterContainer

var grid
var next
var music = 0
var sound = 0
var min_vol

signal button_pressed(button_name)

func _ready():
	grid = find_node("Grid")
	next = find_node("Next")
	min_vol = find_node("Music").get_min()
	find_node("Sound").set_min(min_vol)
	add_cells(grid, 200)
	clear_all_cells()

func add_cells(node, n):
	var num_cells = node.get_child_count()  # how many cells are already in the grid
	while num_cells < n:  # add extra cells as needed
		node.add_child(node.get_child(0).duplicate())  # duplicates the cell that already exists in the grid
		num_cells += 1

func clear_all_cells():
	clear_cells(grid)
	clear_cells(next)	

func clear_cells(node):
	for cell in node.get_children():
		cell.modulate = Color(0)  # goes through all cells and changes its color

func _on_About_button_down():
	$AboutBox.popup_centered()
	emit_signal("button_pressed", "About")

func _on_NewGame_button_down():
	emit_signal("button_pressed", "NewGame")

func _on_Pause_button_down():
	emit_signal("button_pressed", "Pause")

func set_button_state(button, state):
	find_node(button).set_disabled(state)

func set_button_text(button, text):
	find_node(button).set_text(text)

func _on_AboutBox_popup_hide():
	set_button_state("About", false)

func set_button_states(playing):
	set_button_state("NewGame", playing)
	set_button_state("About", playing)
	set_button_state("Pause", !playing)

func _on_Music_value_changed(value):
	music = value
	emit_signal("button_pressed", "Music")

func _on_Sound_value_changed(value):
	sound = value
	emit_signal("button_pressed", "Sound")
