tool
class_name EnemyInvulnerable
extends Enemy

func stomped(count: int):
	# This enemy does not die when stomped.
	AudioPlayer.play_sound(AudioPlayer.BINK)
