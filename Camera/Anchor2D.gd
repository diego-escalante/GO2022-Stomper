class_name Anchor2D
extends Area2D

# The camera's target zool level while in this area.
export var zoom_level := 1.0

# Dictates whether the camera should be locked in an axis or if that axis should follow the target.
export var x_axis_lock := true
export var y_axis_lock := true

# Camera target offset; useful for a camera that looks ahead.
export var target_offset := Vector2.ZERO

# Extents
export var use_extents_as_limit_left := true
export var use_extents_as_limit_right := true
export var use_extents_as_limit_top := true
export var use_extents_as_limit_bottom := true
var extents := Vector2.ZERO

func _ready():
	extents = $CollisionShape2D.get_shape().get_extents()
	extents *= scale
