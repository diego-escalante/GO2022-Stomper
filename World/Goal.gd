extends Node2D

onready var animated_sprite := $AnimatedSprite as AnimatedSprite

func _ready() -> void:
	$Area2D.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body: Node) -> void:
	if body is Player:
		AudioPlayer.play_sound(AudioPlayer.GOAL)
		Events.emit_signal("goal_reached", false)
		animated_sprite.set_animation("Active")
		body.is_input_active = false
		$Area2D.disconnect("body_entered", self, "_on_body_entered")
