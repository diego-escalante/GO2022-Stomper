class_name Saw
extends Path2D

enum MovementType {BOUNCE, LOOP, CLAMP, STATIC}

export(MovementType) var movement_type := MovementType.STATIC
export var speed := 1.0
export var pixels_per_unit := 16
export var is_reversing := false
export var starting_offset := 0.0
var path_length: float
var trip_total_duration: float
var trip_duration := 0.0

onready var path_follow := $PathFollow2D

func _ready():
	Events.connect("death_circle_done", self, "_on_death_circle_done")
	
	if movement_type == MovementType.STATIC:
		speed = 0
	else:
		if curve == null:
			printerr("No curve set on path, enemy will not move.")
		else:
			path_length = curve.get_baked_length()
			trip_total_duration = path_length / (speed * pixels_per_unit)
		
	match movement_type:
		MovementType.LOOP:
			path_follow.loop = true
		MovementType.BOUNCE, MovementType.CLAMP:
			path_follow.loop = false
	
	starting_offset = clamp(starting_offset, 0, 1)
	trip_duration = trip_total_duration * starting_offset
	if not is_reversing:
		path_follow.unit_offset = starting_offset
	else:
		path_follow.unit_offset = 1 - starting_offset


func _physics_process(delta):
	if speed == 0:
		return
		
	var move_amount = delta * speed * pixels_per_unit
		
	match movement_type:
		MovementType.LOOP, MovementType.CLAMP:
			path_follow.offset += move_amount if not is_reversing else -move_amount
		MovementType.BOUNCE:
			trip_duration += delta * (-1 if is_reversing else 1)
			path_follow.offset = lerp(0, path_length, smoothstep(0,1, 1-(trip_duration/trip_total_duration)))
			if trip_duration > trip_total_duration or trip_duration < 0:
				trip_duration = clamp(trip_duration, 0, trip_total_duration)
				is_reversing = !is_reversing

func _on_death_circle_done() -> void:
	z_index = -2
