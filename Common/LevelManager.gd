extends Node

var current_level := 0
var level_path_template := "res://Levels/Level%d.tscn"
var level_load_delay := 1
var dir := Directory.new()

func _ready() -> void:
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("goal_reached", self, "_on_goal_reached")
	
	if dir.open("res://Levels/") != OK:
		printerr("Failed to open Levels directory in Resources.")


func _process(delta):
	if Input.is_action_just_released("debug_restart"):
		SceneChanger.reload_scene()
	elif Input.is_action_just_released("debug_next"):
		_on_goal_reached(false)
	elif Input.is_action_just_released("debug_previous"):
		if current_level > 1:
			current_level -= 1
		var previous_level = level_path_template % current_level
		SceneChanger.change_scene(previous_level, level_load_delay)


func _on_player_died() -> void:
	SceneChanger.reload_scene(level_load_delay)


func _on_goal_reached(noDelay: bool) -> void:
	var delay = 0 if noDelay else level_load_delay
	var new_level = level_path_template % (current_level + 1)
	if dir.file_exists(new_level):
		current_level += 1
		SceneChanger.change_scene(new_level, delay)
	else:
		current_level = 0
		SceneChanger.change_scene("res://Menus/EndScreen.tscn", delay)
