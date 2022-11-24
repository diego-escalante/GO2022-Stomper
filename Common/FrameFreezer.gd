extends Node

func freeze(duration: float) -> void:
	get_tree().paused = true
	yield(get_tree().create_timer(duration), "timeout")
	get_tree().paused = false
