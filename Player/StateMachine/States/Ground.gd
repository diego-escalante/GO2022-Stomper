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
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		player.jump_gravity,
		delta
	)
	
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash") 
	elif not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Air")
		return
