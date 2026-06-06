extends Area2D

var damage = 10
var hit_cooldown = {}

func _on_body_entered(body):
	if body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
	elif body.has_method("receber_dano"):
		body.receber_dano(damage)
