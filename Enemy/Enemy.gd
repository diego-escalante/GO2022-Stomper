tool
class_name Enemy
extends Path2D

enum MovementType {BOUNCE, LOOP, CLAMP, STATIC}
enum Powerup {NONE, DOUBLE_JUMP, DASH}

export(Powerup) var powerup := Powerup.NONE setget _set_powerup
export(MovementType) var movement_type := MovementType.STATIC
export var speed := 1.0
export var pixels_per_unit := 16
export var is_reversing := false
export var starting_offset := 0.0
var path_length: float
var trip_total_duration: float
var trip_duration := 0.0

onready var path_follow := $PathFollow2D as PathFollow2D
onready var animated_sprite := $PathFollow2D/AnimatedSprite as AnimatedSprite
onready var hitbox := $PathFollow2D/Hitbox/CollisionShape2D as CollisionShape2D
onready var stompbox := $PathFollow2D/Stompbox/CollisionShape2D as CollisionShape2D

var is_stomped := false
var gravity := 32 * pixels_per_unit
var velocity := Vector2.ZERO
var stomp_sound: Array

var player: Node2D

# This is a hack to bypass issue with setters using onready variables.
# https://github.com/godotengine/godot-proposals/issues/325
onready var _is_ready := true

func _set_powerup(value) -> void:
	powerup = value
	match powerup:
		Powerup.NONE:
			$PathFollow2D/AnimatedSprite.modulate = Color.white
		Powerup.DASH:
			$PathFollow2D/AnimatedSprite.modulate = Color("#C435CA")
		Powerup.DOUBLE_JUMP:
			$PathFollow2D/AnimatedSprite.modulate = Color("#3BCA35")


func _ready():
	if Engine.editor_hint:
		return
		
	stomp_sound = [
			AudioPlayer.STOMP1, 
			AudioPlayer.STOMP2, 
			AudioPlayer.STOMP3, 
			AudioPlayer.STOMP4, 
			AudioPlayer.STOMP5, 
			AudioPlayer.STOMP6, 
			AudioPlayer.STOMP7, 
			AudioPlayer.STOMP8
	]
		
	var objs = get_tree().get_nodes_in_group("Player")
	if not objs.empty():
		player = objs[0] as Node2D
	
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
	if Engine.editor_hint:
		return
		
	if is_stomped:
		path_follow.rotation_degrees += 720 * delta * (-1 if velocity.x > 0 else 1)
		path_follow.global_position += velocity * delta
		velocity.y += gravity * delta
		return
	
	if movement_type == MovementType.STATIC:	
		if player.global_position.x > global_position.x + 16:
			animated_sprite.flip_h = false
		elif player.global_position.x < global_position.x - 16:
			animated_sprite.flip_h = true
		
		
	if speed == 0:
		return
	
	var prev_x = path_follow.position.x
		
	match movement_type:
		MovementType.LOOP, MovementType.CLAMP:
			var move_amount = delta * speed * pixels_per_unit
			path_follow.offset += move_amount if not is_reversing else -move_amount
		MovementType.BOUNCE:
			trip_duration += delta * (-1 if is_reversing else 1)
			path_follow.offset = lerp(0, path_length, smoothstep(0,1, 1-(trip_duration/trip_total_duration)))
			if trip_duration > trip_total_duration or trip_duration < 0:
				trip_duration = clamp(trip_duration, 0, trip_total_duration)
				is_reversing = !is_reversing
	
	var delta_x = prev_x - path_follow.position.x
	if not is_equal_approx(delta_x, 0):
		animated_sprite.flip_h = delta_x > 0
		
func play_stomp_sound(count: int = 1) -> void:
	count = clamp(count, 1, 8)
	AudioPlayer.play_sound(stomp_sound[count-1])

func stomped(count: int) -> void:
	play_stomp_sound(count)
	is_stomped = true
	hitbox.disabled = true
	stompbox.disabled = true
	movement_type = MovementType.STATIC
	velocity.x = rand_range(-2 * pixels_per_unit, 2 * pixels_per_unit)
	velocity.y = -6 * pixels_per_unit
	get_tree().create_timer(5).connect("timeout", self, "die")
	

func die() -> void:
	queue_free()
