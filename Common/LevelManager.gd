extends Node

export var player_death_to_restart_level_deplay := 1.0

func _ready():
	Events.connect("player_died", self, "_on_player_died")

func _on_player_died():
	yield(get_tree().create_timer(player_death_to_restart_level_deplay), "timeout")
	_restart_level()

func _restart_level():
	get_tree().reload_current_scene()
