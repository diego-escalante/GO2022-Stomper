extends Label

export var is_visible = true

func _ready() -> void:
	percent_visible = 1 if is_visible else 0

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		is_visible = !is_visible
		percent_visible = 1 if is_visible else 0
