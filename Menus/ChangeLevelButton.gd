class_name ChangeLevelButton
extends ChangeSceneButton

export(Texture) var flag_icon

func _ready() -> void:
	if LevelManager.completed_levels.has(text):
		icon = flag_icon
		add_color_override("font_color", Color.black)
		add_color_override("font_color_hover", Color.black)
	
func _on_button_pressed() -> void:
	Events.emit_signal("disable_low_pass")
	LevelManager.current_level = int(text if text != "Start Game" else 1)
	._on_button_pressed()
		
