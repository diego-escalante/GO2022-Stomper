extends PlayerState

func enter(msg:= {}) -> void:
	player.stop_coyote_time()
	player.jumps_left = player.jumps_total
	player.animated_sprite.set_animation("Idle")

func physics_update(delta: float) -> void:
	if (
			Input.is_action_pressed(player.drop_button)
			and player.drop_enabled
			and player.consume_jump_press()
	):
		player.perform_drop()
	
	elif player.jump_enabled and player.consume_jump_press():
		state_machine.transition_to("Air", {"is_jumping": true, "run_immediately": true})
		return
	
	player.update_run_velocity(delta)
	
	if player.velocity.x == 0:
		player.animated_sprite.set_animation("Idle")
	else:
		player.animated_sprite.set_animation("Run")
		
	player.velocity.y += player.jump_gravity * delta
	
	if player.stomp_checker.check(player.calculate_position_delta(player.velocity, player.jump_gravity, delta)):
		var stomped_object = player.stomp_checker.stomped_object.owner
		if stomped_object is Enemy:
			stomped_object.die()
			player.global_position += player.stomp_checker.stomp_delta_position
			state_machine.transition_to("Air", {"is_jumping": true})
			return
		
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		player.jump_gravity,
		delta
	)
	
	if player.dash_enabled and Input.is_action_just_pressed("dash"):
		# Remove a jump from the player when dashing, 
		# otherwise they get an erroneous extra jump
		# after leaving dash in the air.
		player.jumps_left -= 1
		state_machine.transition_to("Dash") 
	elif not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Air")
		return
