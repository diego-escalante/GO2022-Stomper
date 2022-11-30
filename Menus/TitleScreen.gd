extends Control

onready var start_button := get_node("%StartButton")
onready var settings_button := get_node("%SettingsButton")

func _ready():
	start_button.connect("pressed", self, "_on_start_button_pressed")
	settings_button.connect("pressed", self, "_on_settings_button_pressed")


func _on_start_button_pressed():
	Events.emit_signal("start_game")
	start_button.disabled = true


func _on_settings_button_pressed():
	pass
