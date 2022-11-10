class_name Enemy
extends KinematicBody2D

func die() -> void:
	queue_free()
