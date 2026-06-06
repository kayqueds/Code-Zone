extends Control

@onready var audio = $"victory sound"

func _ready():
	audio.play()

	await get_tree().create_timer(15.0).timeout

	get_tree().change_scene_to_file("res://scene/start.tscn")
