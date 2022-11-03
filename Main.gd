extends Node2D

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func _process(delta) -> void:
	if Input.is_action_just_pressed("ui_select"):
		VisualServer.set_default_clear_color(Color(rng.randf(), rng.randf(), rng.randf()))
