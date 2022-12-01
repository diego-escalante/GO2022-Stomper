extends AudioStreamPlayer

export var current_cutoff_hz := 20000
onready var audio_effect = AudioServer.get_bus_effect(2, 0) as AudioEffectLowPassFilter
onready var animation_player := $AnimationPlayer

func _ready():
	Events.connect("enable_low_pass", self, "_enable_low_pass")
	Events.connect("disable_low_pass", self, "_disable_low_pass")

func _physics_process(_delta):
	audio_effect.cutoff_hz = current_cutoff_hz

func _enable_low_pass() -> void:
	if current_cutoff_hz == 20000:
		animation_player.play("enableFilter")
	
func _disable_low_pass() -> void:
	if current_cutoff_hz != 20000:
		animation_player.play_backwards("enableFilter")
