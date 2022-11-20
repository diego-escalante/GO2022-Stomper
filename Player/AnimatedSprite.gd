extends AnimatedSprite

func _ready() -> void:
	connect("animation_finished", self, "_on_animation_finished")
	
func _on_animation_finished() -> void:
	if get_animation() == "Land":
		set_animation("Idle")
