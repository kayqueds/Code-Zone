extends Area2D

@export var next_scene := "res://scene/boss_room.tscn"
var already_triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if already_triggered:
		return

	if body.is_in_group("player"):
		already_triggered = true
		get_tree().change_scene_to_file(next_scene)
