extends Area2D

var damage = 10

func activate():
	monitoring = true
	visible = true

func deactivate():
	monitoring = false
	visible = false
