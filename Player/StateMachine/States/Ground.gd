extends PlayerState

var time_start: int

func _ready():
	time_start = OS.get_ticks_msec()

func enter(msg:= {}) -> void:
	player.stop_coyote_time()
	player.jumps_left = player.jumps_total
	if (OS.get_ticks_msec() - time_start) > 100:
		player.animated_sprite.set_animation("Land")
		player.animation_player.play("Squash")
	player.stomp_combo = 0

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
	
	if player.animated_sprite.get_animation() != "Land":
		if player.velocity.x == 0 and player.animated_sprite.get_animation() != "Idle":
			player.animated_sprite.set_animation("Idle")
		elif player.velocity.x != 0:
			player.animated_sprite.set_animation("Run")
		
	player.velocity.y += player.jump_gravity * delta
	
	if player.perform_stomp_if_able(player.jump_gravity, delta):
		state_machine.transition_to("Air", {"is_jumping": true, "is_stomping": true})
		return
		
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		player.jump_gravity,
		delta
	)
	
	if player.dash_enabled and player.is_input_active and Input.is_action_just_pressed("dash"):
		# Remove a jump from the player when dashing, 
		# otherwise they get an erroneous extra jump
		# after leaving dash in the air.
		player.jumps_left -= 1
		state_machine.transition_to("Dash") 
	elif not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Air")
		return
