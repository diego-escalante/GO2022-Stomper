extends PlayerState

var gravity: float

func enter(msg:= {}) -> void:
	player.animated_sprite.set_animation("Jump")
	
	if msg.get("is_jumping", false):
		# Perform jump.
		player.velocity.y = -(
				player.jump_speed if player.jumps_total == player.jumps_left else
				player.multi_jump_speed
		)
		gravity = player.jump_gravity
		if player.min_jump_enabled and not Input.is_action_pressed(player.jump_button):
			gravity = player.min_jump_gravity
		player.jumps_left -= 1
		
	if msg.get("run_immediately", false):
		physics_update(get_physics_process_delta_time())


func physics_update(delta: float) -> void:
	if player.jumps_left > 0 and player.jump_enabled and player.consume_jump_press():
		state_machine.transition_to("Air", {"is_jumping": true, "run_immediately": true})
		return
	
	# Update the player velocity.
	player.update_run_velocity(delta)
	
	# Apply gravity.
	if player.min_jump_enabled and Input.is_action_just_released(player.jump_button):
		gravity = player.min_jump_gravity
	if player.fast_fall_enabled and player.velocity.y > 0:
		gravity = player.fast_fall_gravity
	player.velocity.y += gravity * delta
	
	# Clamp by terminal velocity.
	if player.terminal_velocity_enabled:
		player.velocity.y = clamp(player.velocity.y, -player.terminal_velocity, player.terminal_velocity)
		
	if player.perform_stomp_if_able(gravity, delta):
		state_machine.transition_to("Air", {"is_jumping": true})
		return

	# Move player.
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		gravity,
		delta
	)
	
	# Handle transitions.
	if player.dash_enabled and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif player.is_on_floor():
		state_machine.transition_to("Ground")
		return
