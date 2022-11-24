class_name StompChecker
extends Node2D

var stomped_object
var stomp_delta_position

onready var downCasts := $VerticalCasts.get_children()
onready var rightCast := $HorizontalCasts/RightCast
onready var leftCast := $HorizontalCasts/LeftCast
onready var cooldown_timer := $CooldownTimer as Timer

# TODO: This technically hits my infamous corner case, but in this case, it is
# extremely unlikely to cause an issue. Fix it if it becomes an issue.
func check(position_delta: Vector2) -> bool:
	if cooldown_timer.time_left > 0 or not owner.is_active:
		return false
	
	var stomp_happened = false
	stomp_delta_position = Vector2.ZERO
	stomped_object = null
	if position_delta.x != 0 and position_delta.y >= 0:
		var hCast: RayCast2D = rightCast if position_delta.x > 0 else leftCast
		var cast_to := hCast.cast_to
		cast_to.x = position_delta.x
		hCast.cast_to = cast_to
		hCast.force_raycast_update()
		
		if hCast.is_colliding():
			stomp_happened = true
			stomp_delta_position.x = hCast.get_collision_point().x - hCast.global_position.x
			stomped_object = hCast.get_collider()
			
	if position_delta.y > 0:
		for downCast in downCasts:
			var cast_to = downCast.cast_to
			cast_to.y = position_delta.y
			downCast.cast_to = cast_to
			downCast.force_raycast_update()
			
			if downCast.is_colliding():
				stomp_happened = true
				stomp_delta_position.y = downCast.get_collision_point().y - downCast.global_position.y
				stomped_object = downCast.get_collider()
				break
				
	if stomp_happened:
		cooldown_timer.start()

	return stomp_happened
