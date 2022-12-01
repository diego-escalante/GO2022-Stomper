extends Control	
	
func animate() -> void:
	$Menu/Stats.text = StatTracker.get_stat_string()
	$AnimationPlayer.play("Appear")
