class_name Anchor2D
extends Area2D

# The camera's target zool level while in this area.
export var zoom_level := 1.0

# Dictates whether the camera should be locked in an axis or if that axis should follow the target.
export var x_axis_lock := true
export var y_axis_lock := true

# Camera target offset; useful for a camera that looks ahead.
export var target_offset := Vector2.ZERO

# Should the camera lock onto the anchor instantly?
export var instant_lock := false
