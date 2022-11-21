extends Node2D

onready var animated_sprite := $AnimatedSprite as AnimatedSprite

func _ready() -> void:
	$Area2D.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body: Node) -> void:
	Events.emit_signal("goal_reached", false)
	animated_sprite.set_animation("Active")
