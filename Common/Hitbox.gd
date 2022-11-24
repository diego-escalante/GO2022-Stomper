extends Area2D

func _ready():
	connect("body_entered", self, "_on_Hitbox_body_entered")

func _on_Hitbox_body_entered(body):
	if body is Player:
		var node2d := owner as Node2D
		node2d.z_index = 2
		body.player_die()
