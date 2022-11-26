extends Node

export var number_of_players := 8

const BINK = preload("res://Audio/bink.wav")
const DEATH1 = preload("res://Audio/death1.wav")
const DEATH2 = preload("res://Audio/death2.wav")
const GOAL = preload("res://Audio/goal.wav")
const JUMP = preload("res://Audio/jump.wav")
const DOUBLE_JUMP = preload("res://Audio/double_jump.wav")
const STOMP1 = preload("res://Audio/stomp1.wav")
const STOMP2 = preload("res://Audio/stomp2.wav")
const STOMP3 = preload("res://Audio/stomp3.wav")
const STOMP4 = preload("res://Audio/stomp4.wav")
const STOMP5 = preload("res://Audio/stomp5.wav")
const STOMP6 = preload("res://Audio/stomp6.wav")
const STOMP7 = preload("res://Audio/stomp7.wav")
const STOMP8 = preload("res://Audio/stomp8.wav")
const BOUNCE1 = preload("res://Audio/bounce1.wav")
const BOUNCE2 = preload("res://Audio/bounce2.wav")
const BOUNCE3 = preload("res://Audio/bounce3.wav")
const BOUNCE4 = preload("res://Audio/bounce4.wav")
const BOUNCE5 = preload("res://Audio/bounce5.wav")
const BOUNCE6 = preload("res://Audio/bounce6.wav")
const BOUNCE7 = preload("res://Audio/bounce7.wav")
const BOUNCE8 = preload("res://Audio/bounce8.wav")
const DASH = preload("res://Audio/dash.wav")

var current_player_index := number_of_players-1
onready var audio_players := $AudioPlayers


func _ready():
	for i in range(number_of_players):
		var audio_player := AudioStreamPlayer.new()
		audio_player.pause_mode = Node.PAUSE_MODE_PROCESS
		audio_player.bus = "Sound"
		audio_players.add_child(audio_player)


func play_sound(sound: AudioStream) -> void:	
	var audio_player := get_next_player()
	audio_player.stream = sound
	audio_player.play()

# Attempts to find the next available player via round robin, skipping players
# that are still active. If all players are active, 
func get_next_player() -> AudioStreamPlayer:
	var iterations := 0
	while true:
		iterations += 1
		current_player_index = (current_player_index + 1) % number_of_players
		
		var audio_player: AudioStreamPlayer = audio_players.get_child(current_player_index)
		if not audio_player.is_playing():
			return audio_player
		elif iterations == number_of_players:
			# We cycled through all players; all unavailable. So take the next one anyway.
			printerr("Could not find an available AudioStreamPlayer. Taking an in-progress one.")
			current_player_index = (current_player_index + 1) % number_of_players
			return audio_players.get_child(current_player_index) as AudioStreamPlayer
			
	# Impossible to get here; this just makes the interpreter happy.
	return null
