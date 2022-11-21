class_name Enemy
extends Path2D

enum MovementType {BOUNCE, LOOP, CLAMP, STATIC}

export(MovementType) var movement_type := MovementType.STATIC
export var speed := 1.0
export var pixels_per_unit := 16
export var is_reversing := false
var path_length: float

onready var path_follow := $PathFollow2D
onready var animated_sprite := $PathFollow2D/AnimatedSprite as AnimatedSprite

func _ready():
	if movement_type == MovementType.STATIC:
		speed = 0
	else:
		if curve == null:
			printerr("No curve set on path, enemy will not move.")
		else:
			path_length = curve.get_baked_length()
		
	match movement_type:
		MovementType.LOOP:
			path_follow.loop = true
		MovementType.BOUNCE, MovementType.CLAMP:
			path_follow.loop = false
			
	if not is_reversing:
		path_follow.unit_offset = 0
	else:
		path_follow.unit_offset = 1


func _physics_process(delta):
	if speed == 0:
		return
	
	var prev_x = path_follow.position.x
	var move_amount = delta * speed * pixels_per_unit
		
	match movement_type:
		MovementType.LOOP, MovementType.CLAMP:
			path_follow.offset += move_amount if not is_reversing else -move_amount
		MovementType.BOUNCE:
			if not is_reversing:
				if path_follow.offset + move_amount > path_length:
					is_reversing = true
					path_follow.offset = path_length * 2 - path_follow.offset - move_amount
				else:
					path_follow.offset += move_amount
			else:
				if path_follow.offset - move_amount < 0:
					is_reversing = false
					path_follow.offset = move_amount - path_follow.offset 
				else:
					path_follow.offset -= move_amount
	
	var delta_x = prev_x - path_follow.position.x
	if not is_equal_approx(delta_x, 0):
		animated_sprite.flip_h = delta_x > 0


func die() -> void:
	queue_free()
