class_name Explosion
extends AnimatedSprite

const PIXELS_PER_UNIT := 16

export var appearing_duration := 0.5
export var speed := 4.25
export var direction := Vector2.ZERO setget set_direction
export var decceleration := 0.1

onready var timer := $Timer as Timer

func _ready():
	direction = direction.normalized()
	timer.connect("timeout", self, "_on_timer_timeout")
	connect("animation_finished", self, "_on_appear_finished")
	play("Appear", false)
	

func set_direction(value: Vector2) -> void:
	direction = value


func _physics_process(delta: float) -> void:
	global_position += direction * speed * PIXELS_PER_UNIT * delta
	speed = max(0, speed - decceleration)


func _on_appear_finished() -> void:
	timer.start(appearing_duration)


func _on_timer_timeout() -> void:
	disconnect("animation_finished", self, "_on_appear_finished")
	connect("animation_finished", self, "_on_disappear_finished")
	play("Appear", true)
	

func _on_disappear_finished() -> void:
	queue_free()
