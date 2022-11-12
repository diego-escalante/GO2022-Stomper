extends Control

onready var restart_button := get_node("%RestartButton")

func _ready():
	restart_button.connect("pressed", self, "_on_start_button_pressed")


func _on_start_button_pressed():
	SceneChanger.change_scene("res://Menus/TitleScreen.tscn")
	restart_button.disabled = true
