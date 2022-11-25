extends Button

export var scene: String

func _ready() -> void:
	if not scene:
		printerr("There is no scene assigned to the ChangeSceneButton!")
		return
	
	connect("pressed", self, "_on_button_pressed")
	

func _on_button_pressed() -> void:
	SceneChanger.change_scene(scene, 0)
	disconnect("pressed", self, "_on_button_pressed")
