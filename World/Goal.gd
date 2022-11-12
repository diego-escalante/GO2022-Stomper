extends Node2D

func _ready() -> void:
	$Area2D.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body: Node) -> void:
	Events.emit_signal("goal_reached", false)
