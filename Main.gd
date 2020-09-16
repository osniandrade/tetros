extends Node2D

enum { STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE }

var gui
var state = STOPPED
var music_position = 0.0

const DISABLED = true
const ENABLED = false

func _ready():
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)

func _button_pressed(button_name):
	match button_name:
		"NewGame":
			gui.set_button_states(DISABLED)
			_start_game()
		"Pause":
			if state == PLAYING:
				gui.set_button_text("Pause", "Resume")
				state = PAUSED
				_music(PAUSE)
			else:
				gui.set_button_text("Pause", "Pause")
				state = PLAYING
				_music(PLAY)
		"Music":
			if state == PLAYING:
				if gui.music:
					_music(PLAYING)
				else:
					_music(STOP)
		"Sound":
			# copy gui.sound value to data
			print("Changed sound setting")
		"About":
			gui.set_button_state("About", DISABLED)

func _start_game():
	print("Game Playing")
	state = PLAYING
	music_position = 0.0
	_music(PLAY)

func _music(action):
	if gui.music and action == PLAY:
		$MusicPlayer.play(music_position)
		print("Music started")
	else:
		music_position = $MusicPlayer.get_playback_position()
		$MusicPlayer.stop()
		print("Music stopped")
