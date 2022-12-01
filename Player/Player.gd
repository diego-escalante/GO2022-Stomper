class_name Player
extends KinematicBody2D

signal gained_double_jump
signal gained_dash

enum Direction {RIGHT = 1, LEFT = -1}

export var pixels_per_unit := 16

# Base run
export var run_enabled := true
export var run_speed := 5.0
export var run_left_button := "run_left"
export var run_right_button := "run_right"

# Acceleration
export var acceleration_enabled := false
export var time_to_run_speed := 0.1
onready var _acceleration := run_speed / time_to_run_speed

# Base jump
export var jump_enabled := true
export var jump_height := 3.0
export var jump_distance := 1.75
export var jump_button := "jump"
onready var jump_speed := 2 * jump_height * run_speed / jump_distance
onready var jump_gravity := 2 * jump_height * run_speed * run_speed / (jump_distance * jump_distance)
onready var big_jump_speed := sqrt(2 * jump_gravity * (jump_height * 2))

# Minimum jump
export var min_jump_enabled := true
export var min_jump_height := 1.0
onready var min_jump_gravity := jump_speed * jump_speed / (2 * min_jump_height)
onready var _min_jump_distance := run_speed * jump_speed / min_jump_gravity

# Multi jump
export var multi_jump_enabled := true
export var multi_jumps := 1
export var multi_jump_height := 2.0
onready var multi_jump_speed := sqrt(2 * jump_gravity * multi_jump_height)
onready var _multi_jump_distance := run_speed * multi_jump_speed / jump_gravity

# Dash
export var dash_enabled := true
export var dash_distance := 4.0
export var time_to_dash_distance := 0.1
onready var dash_speed := dash_distance / time_to_dash_distance

# Fast fall
export var fast_fall_enabled := true
export var fast_fall_distance := 1.25
onready var fast_fall_gravity := 2 * jump_height * run_speed * run_speed / (fast_fall_distance * fast_fall_distance)

# Drop
export var drop_enabled := true
export var drop_button := "drop"
export var oneway_collision_mask_bit_index := 2
onready var _drop_timer := _initialize_timer(0.1, "_on_drop_timer_timeout")

# Terminal velocity
export var terminal_velocity_enabled := true
export var terminal_velocity_factor := 3.0
onready var terminal_velocity := jump_speed * terminal_velocity_factor

# Coyote time
export var coyote_time := 0.1
onready var _coyote_timer := _initialize_timer(coyote_time, "_on_coyote_timer_timeout")

# Jump buffer
export var jump_buffer_time := 0.1
onready var _jump_buffer_timer := _initialize_timer(jump_buffer_time)

onready var animated_sprite := $AnimatedSprite as AnimatedSprite
onready var stomp_checker := $StompChecker as StompChecker
onready var jumps_total: int = multi_jumps + 1 if multi_jump_enabled else 1
onready var jumps_left := jumps_total
var velocity := Vector2.ZERO
var facing_direction: int = Direction.RIGHT
onready var collision_shape := $CollisionShape2D as CollisionShape2D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var auto_jump_timer := $AutoJumpTimer as Timer

var stomp_combo := 0

var explosion := preload("res://Common/Explosion.tscn")
var bonk := preload("res://Common/Bonk.tscn")

var is_active := true
var is_input_active := true

func _ready() -> void:
	animated_sprite.playing = true
	auto_jump_timer.connect("timeout", self, "_on_auto_jump")


func _on_auto_jump() -> void:
	_jump_buffer_timer.start()

func update_run_velocity(delta: float) -> void:
	if not is_input_active:
		velocity.x = 0
		return
	var target_velocity := 0.0
	if run_enabled:
		target_velocity = Input.get_axis(run_left_button, run_right_button) * run_speed

	if acceleration_enabled:
		velocity.x = move_toward(velocity.x, target_velocity, _acceleration * delta)
	else:
		velocity.x = target_velocity

func move_and_slide_with_vertical_velocity_verlet(
		velocity: Vector2, 
		vertical_acceleration: float, 
		delta: float
) -> Vector2:
	# This function tries to mimic the basic move_and_slide but uses velocity verlet for the y-axis, 
	# as this acceleration is (mostly) constant for a platformer. To compensate for move_and_slide 
	# multiplying by delta internally, the standard velocity verlet equation vt+0.5at^2 is first 
	# divided by delta (t). Additionally, we cannot assign the result of move_and_slide back to 
	# velocity because the input wasn't actually just velocity; instead velocity has to be updated 
	# by looking at the collisions resulting from the translation.
	# This also takes in a scale of pixels_per_unit so that velocities and accelerations can remain 
	# represented in more intuitive developer-defined units (e.g. player height, block size, etc.)
	# rather than pixels.
	
	move_and_slide(
			pixels_per_unit * (velocity + 0.5 * Vector2.UP * vertical_acceleration * delta), 
			Vector2.UP, false, 8, 0
	)
	
	if velocity.x > 0:
		facing_direction = Direction.RIGHT
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		facing_direction = Direction.LEFT
		animated_sprite.flip_h = true
	

	# This if and elif for sure fixes the corner issue. Real "edge" case if you know what I mean.
	if is_on_wall():
		velocity.x = 0
	elif is_on_floor() or is_on_ceiling():
		velocity.y = 0
	return velocity
	

func calculate_position_delta(
		velocity: Vector2, 
		vertical_acceleration: float, 
		time_delta: float
) -> Vector2:
	return pixels_per_unit * (velocity + 0.5 * Vector2.UP * vertical_acceleration * time_delta) * time_delta

# _unhandled_input seems to not actually handle input 100% correctly in an html build.
# So I'm using _physics_process instead.
func _physics_process(delta) -> void:
	if is_input_active and Input.is_action_just_pressed(jump_button):
		_jump_buffer_timer.start()
		
	if Input.is_action_just_pressed("esc"):
		Events.emit_signal("enable_low_pass")
		SceneChanger.change_scene("res://Menus/LevelSelect.tscn")


func is_jump_press_buffered() -> bool:
	return not _jump_buffer_timer.is_stopped()


func consume_jump_press() -> bool:
	if _jump_buffer_timer.is_stopped():
		return false
	_jump_buffer_timer.stop()
	return true


func perform_drop() -> void:
	set_collision_mask_bit(oneway_collision_mask_bit_index, false)
	_drop_timer.start()


func _on_drop_timer_timeout() -> void:
	set_collision_mask_bit(oneway_collision_mask_bit_index, true)


func start_coyote_time() -> void:
	_coyote_timer.start()
	

func stop_coyote_time() -> void:
	_coyote_timer.stop()


func _on_coyote_timer_timeout() -> void:
	# If the player has all of its jumps after coyote time, take away their main jump.
	if jumps_left == jumps_total:
		 jumps_left -= 1


func _initialize_timer(wait_time: float, timeout_callback: String = "") -> Timer:
	var new_timer = Timer.new()
	new_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	new_timer.one_shot = true
	new_timer.wait_time = wait_time
	if not timeout_callback.empty():
		new_timer.connect("timeout", self, timeout_callback)
	add_child(new_timer)
	return new_timer


func player_die() -> void:
	if is_active:
		is_active = false
		AudioPlayer.play_sound(AudioPlayer.DEATH1)
		Events.emit_signal("enable_low_pass")
		yield(FrameFreezer.freeze(0.3), "completed")
		AudioPlayer.play_sound(AudioPlayer.DEATH2)
		Events.emit_signal("add_trauma", 0.5)
		animated_sprite.visible = false
		collision_shape.disabled = true
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				if i == 0 and j == 0:
					continue
				var inst := (explosion.instance()) as Explosion
				inst.set_direction(Vector2(i, j))
				inst.modulate = animated_sprite.modulate
				add_child(inst)
		yield(get_tree().create_timer(1), "timeout")
		Events.emit_signal("player_died")
		StatTracker.deaths += 1

func unpause() -> void:
	get_tree().paused = false
	
func perform_stomp_if_able(current_gravity: float, time_delta: float) -> bool:
	if stomp_checker.check(calculate_position_delta(velocity, current_gravity, time_delta)):
		FrameFreezer.freeze(0.05)
		Events.emit_signal("add_trauma", 0.15)
		var stomped_object = stomp_checker.stomped_object.owner
		if stomped_object is Enemy:
			var enemy := stomped_object as Enemy
			if not enemy is EnemyInvulnerable:
				stomp_combo += 1
			match enemy.powerup:
				Enemy.Powerup.DASH:
					dash_enabled = true
					set_multi_jump_enabled(false)
					animated_sprite.modulate = enemy.animated_sprite.modulate
					emit_signal("gained_dash")
				Enemy.Powerup.DOUBLE_JUMP:
					dash_enabled = false
					set_multi_jump_enabled(true)
					animated_sprite.modulate = enemy.animated_sprite.modulate
					emit_signal("gained_double_jump")
			if stomped_object is EnemyBigBounce:
				velocity.y = -big_jump_speed
				
			var new_bonk := bonk.instance() as Node2D
			owner.add_child(new_bonk)
			new_bonk.global_position = Vector2(
					(global_position.x + stomped_object.path_follow.global_position.x)/2, 
					global_position.y + 8
			)
			stomped_object.stomped(stomp_combo)
			global_position += stomp_checker.stomp_delta_position
			jumps_left = jumps_total
			return true
	return false
	
func set_multi_jump_enabled(is_enabled: bool) -> void:
	multi_jump_enabled = is_enabled
	jumps_total = multi_jumps + 1 if multi_jump_enabled else 1
	if is_enabled:
		jumps_left += 1
	elif jumps_left > 1:
		jumps_left = 1
