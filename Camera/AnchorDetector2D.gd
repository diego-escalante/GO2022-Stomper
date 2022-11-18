class_name AnchorDetector2D
extends Area2D

signal anchor_detected(anchor)
signal anchor_detached

var _areas := []

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _on_area_entered(area: Anchor2D) -> void:
	if _areas.has(area):
		return
	else:
		_areas.push_front(area)
	emit_signal("anchor_detected", area)


func _on_area_exited(area: Anchor2D) -> void:
	# Detach if this is the last anchor exited. Otherwise, attach to the next one in the stack.
	if _areas.has(area):
		_areas.remove(_areas.find(area))
	if _areas.empty():
		emit_signal("anchor_detached")
	else:
		emit_signal("anchor_detected", _areas[0])
