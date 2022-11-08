extends Node
# SceneChanger is a singleton (autoloaded) used to change or reload a scene with a basic transition.

export var player_death_to_restart_level_deplay := 1.0
var tween: SceneTreeTween
onready var fader := $Control/Fader

# Reloads the current scene with a screen transition.
func reload_scene(delay: float = 0) -> void:
	yield(_fadeTo(Color("ff000000"), 0.5, delay), "completed")
	get_tree().reload_current_scene()
	yield(_fadeTo(Color("00000000"), 0.5), "completed")


# Changes the scene with a screen transition.
func change_scene(scene: String, delay: float = 0) -> void:
	yield(_fadeTo(Color("ff000000"), 0.5, delay), "completed")
	if get_tree().change_scene(scene) != OK:
		printerr("Failed to change to scene %s" % scene)
		
	yield(_fadeTo(Color("00000000"), 0.5), "completed")


# Fades the screen to a given color.
func _fadeTo(
		fadeToColor: Color, 
		fadeDuration: float, 
		startDelay: float = 0, 
		endDelay: float = 0
) -> void:
	if tween:
		tween.kill()
	if startDelay > 0:
		yield(get_tree().create_timer(startDelay), "timeout")
	if fadeDuration > 0:
		tween = create_tween()
		yield(tween.tween_property(fader, "color", fadeToColor, fadeDuration), "finished")
	else:
		print_debug("Useless call to _fadeTo with no duration.")
		fader.color = fadeToColor
	if endDelay > 0:
		yield(get_tree().create_timer(endDelay), "timeout")

# Fades the screen from a starting color to another color.
func _fadeFromTo(
		fadeFromColor: Color, 
		fadeToColor: Color, 
		fadeDuration: float, 
		startDelay: float = 0, 
		endDelay: float = 0
) -> void:
	fader.color = fadeFromColor
	_fadeTo(fadeToColor, fadeDuration, startDelay, endDelay)
