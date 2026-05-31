extends Area2D

func _on_body_entered(body):

	print("ENCOSTOU:", body.name)

	if body.has_method("die") and not body.invulnerable:
		body.die()
