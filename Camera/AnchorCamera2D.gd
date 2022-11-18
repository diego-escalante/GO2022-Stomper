# Inspired by GDQuest's tutorial:
# https://www.gdquest.com/tutorial/godot/2d/anchor-camera/

class_name AnchorCamera2D
extends Camera2D

# Distance to the target (in pixels) below which the camera slows down.
const SLOW_RADIUS := 300.0

# Maximum speed in pixels per second.
export var max_speed := 2000.0
# Mass to slow down the camera's movement.
export var mass := 2.0

var _velocity = Vector2.ZERO
# Global position of an anchor area that the camera follows. If it's equal to Vector2.ZERO,
# there is no anchor, the camera follows its owner.
var _anchor_position: Vector2
var _target_zoom := 1.0
var _x_axis_lock := false
var _y_axis_lock := false
var _target_offset := Vector2.ZERO


func _ready() -> void:
	# Set the node as top-level to let it move independently of its parent.
	set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	update_zoom()
	
	var target_position := Vector2.ZERO
	target_position.x = _anchor_position.x if _x_axis_lock else owner.global_position.x
	target_position.y = _anchor_position.y if _y_axis_lock else owner.global_position.y
	target_position += _target_offset
	
	arrive_to(target_position)


# Don't forget to connect an Anchor Detector's signal to this function.
func _on_AnchorDetector2D_anchor_detected(anchor: Anchor2D) -> void:
	_anchor_position = anchor.global_position
	_target_zoom = anchor.zoom_level
	_x_axis_lock = anchor.x_axis_lock
	_y_axis_lock = anchor.y_axis_lock
	_target_offset = anchor.target_offset


# Don't forget to connect an Anchor Detector's signal to this function.
func _on_AnchorDetector2D_anchor_detached() -> void:
	_anchor_position = Vector2.ZERO
	_target_offset = Vector2.ZERO
	_target_zoom = 1.0
	_x_axis_lock = false
	_y_axis_lock = false


# Smoothly update the zoom level using lerp.
func update_zoom() -> void:
	if is_equal_approx(zoom.x, _target_zoom):
		return
	var new_zoom_level: float = lerp(
			zoom.x, _target_zoom, 1.0 - pow(0.008, get_physics_process_delta_time())
	)
	zoom = Vector2(new_zoom_level, new_zoom_level)


# Gradually steer the camera to the target_position.
func arrive_to(target_position: Vector2) -> void:
	var distance_to_target := position.distance_to(target_position)
	# We approach the `target_position` at maximum speed, taking the zoom into account, until we
	# get close to the target point.
	var desired_velocity := (target_position - position).normalized() * max_speed * zoom.x
	# If we're close enough to the target, we gradually slow down the camera.
	if distance_to_target < SLOW_RADIUS * zoom.x:
		desired_velocity *= (distance_to_target / (SLOW_RADIUS * zoom.x))
		
	_velocity += (desired_velocity - _velocity) / mass
	position += _velocity * get_physics_process_delta_time()
