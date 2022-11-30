extends RichTextLabel

export var powerup := "double_jump"
var player: Player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	player.connect("gained_" + powerup, self, "_on_player_gained_powerup")

func _on_player_gained_powerup() -> void:
	visible_characters = -1
	player.disconnect("gained_" + powerup, self, "_on_player_gained_powerup")
	
