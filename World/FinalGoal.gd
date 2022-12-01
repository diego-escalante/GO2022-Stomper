extends Node2D

onready var animated_sprite := $AnimatedSprite as AnimatedSprite

func _ready() -> void:
	$Area2D.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body: Node) -> void:
	if body is Player:
		StatTracker.complete_level(18)
		LevelManager.completed_levels["18"] = "Completed"
		AudioPlayer.play_sound(AudioPlayer.GOAL)
		animated_sprite.set_animation("Active")
		body.is_input_active = false
		yield(get_tree().create_timer(0.5), "timeout")
		body.auto_jump_timer.start()
		body._on_auto_jump()
		$Area2D.disconnect("body_entered", self, "_on_body_entered")
		yield(get_tree().create_timer(1.5), "timeout")
		$"../CanvasLayer/EndScreen".animate()
