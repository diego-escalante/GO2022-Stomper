extends Node

var current_level := 0
var level_path_template := "res://Levels/Level%d.tscn"
var level_load_delay := 1.0
var dir := Directory.new()

func _ready() -> void:
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("goal_reached", self, "_on_goal_reached")
	
	if dir.open("res://Levels/") != OK:
		printerr("Failed to open Levels directory in Resources.")

	
# TODO: For debugging purposes. Delete this.
func _process(delta):
	if Input.is_action_just_released("ui_page_up"):
		SceneChanger.reload_scene()


func _on_player_died() -> void:
	SceneChanger.reload_scene(level_load_delay)


func _on_goal_reached() -> void:
	var new_level = level_path_template % (current_level + 1)
	if dir.file_exists(new_level):
		current_level += 1
		SceneChanger.change_scene(new_level, level_load_delay)
	else:
		print_debug("Next level not found.")
