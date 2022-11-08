extends Control

onready var start_button := get_node("%StartButton")
onready var settings_button := get_node("%SettingsButton")
onready var credits_button := get_node("%CreditsButton")

func _ready():
	start_button.connect("pressed", self, "_on_start_button_pressed")
	settings_button.connect("pressed", self, "_on_settings_button_pressed")
	credits_button.connect("pressed", self, "_on_credits_button_pressed")


func _on_start_button_pressed():
	SceneChanger.change_scene("res://Main.tscn")
	pass


func _on_settings_button_pressed():
	pass
	

func _on_credits_button_pressed():
	pass
