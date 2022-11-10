extends Node

var player_death_to_restart_level_deplay := 1.0

func _ready() -> void:
	Events.connect("player_died", self, "_on_player_died")
	
func _process(delta):
	if Input.is_action_just_released("ui_page_up"):
		SceneChanger.reload_scene()

func _on_player_died() -> void:
	SceneChanger.reload_scene(player_death_to_restart_level_deplay)
