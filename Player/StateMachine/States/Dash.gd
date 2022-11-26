extends PlayerState

func enter(msg:= {}) -> void:
	player.animated_sprite.set_animation("Dash")
	player.velocity.y = 0
	player.velocity.x = (
			player.dash_speed if player.facing_direction == player.Direction.RIGHT 
			else -player.dash_speed
	)
	player.dash_enabled = false
	player.animated_sprite.modulate = Color.white
	Events.emit_signal("add_trauma", 0.2)
	AudioPlayer.play_sound(AudioPlayer.DASH)
	yield(get_tree().create_timer(player.time_to_dash_distance), "timeout")
	# TODO: This has a rare bug: When leaving dash while on the ground, if the player 
	# immediately jumps on the very next frame (which is not too difficult to do thanks to jump
	# buffering), the player will be missing an expected jump. The perception is that they
	# are grounded, but because dash solely transitions to Air, the jump is missing.
	# The fix is to manually detect if the player is grounded, and if so, transition to Ground
	# instead of Air.
	state_machine.transition_to("Air")


func physics_update(delta: float) -> void:
	if player.perform_stomp_if_able(0, delta):
		state_machine.transition_to("Air", {"is_jumping": true, "is_stomping": true})
		return
	
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		0,
		delta
	)
