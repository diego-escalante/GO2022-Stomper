extends Node

var deaths := 0
var levels_completed := {}
var total_levels := 18
var start_time_secs := OS.get_unix_time()
	

func restart_time() -> void:
	start_time_secs = OS.get_unix_time()


func get_elapsed_time() -> String:
	var total_elapsed := OS.get_unix_time() - start_time_secs
	return "%sm %ss" % [total_elapsed / 60, total_elapsed % 60]
	
func complete_level(level: int) -> void:
	levels_completed[level] = "Completed"
	
	
func get_stat_string() -> String:
	return """Deaths: %s
	Time Duration: %s
	Levels Completed : %s
	""" % [deaths, get_elapsed_time(), str(levels_completed.size()) + "/" + str(total_levels)]
