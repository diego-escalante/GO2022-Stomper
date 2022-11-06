extends PlayerState

var dist := 0.0

func enter(msg:= {}) -> void:
	print("dash speed: %s" % player.dash_speed)
	print("dash time: %s" % player.time_to_dash_distance)
	print("dash distance: %s" % player.dash_distance)
	dist = player.position.x
	player.velocity.y = 0
	player.velocity.x = player.dash_speed if player.facing_direction == player.Direction.RIGHT else -player.dash_speed
	yield(get_tree().create_timer(player.time_to_dash_distance), "timeout")
	state_machine.transition_to("Air")


func physics_update(delta: float) -> void:
	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		0,
		delta
	)

		
func exit() -> void:
	print("units traveled: %s" % ((player.position.x - dist) / player.pixels_per_unit))
