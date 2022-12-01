extends Control

onready var start_button := get_node("%StartButton")

func _ready():
	start_button.connect("pressed", self, "_on_start_button_pressed")


func _on_start_button_pressed():
	start_button.disabled = true
	Events.emit_signal("start_game")
