tool
class_name EnemyBigBounce
extends Enemy

func _ready():
	._ready()
	if Engine.editor_hint:
		return
	stomp_sound = [
			AudioPlayer.BOUNCE1, 
			AudioPlayer.BOUNCE2, 
			AudioPlayer.BOUNCE3, 
			AudioPlayer.BOUNCE4, 
			AudioPlayer.BOUNCE5, 
			AudioPlayer.BOUNCE6, 
			AudioPlayer.BOUNCE7, 
			AudioPlayer.BOUNCE8
	]
