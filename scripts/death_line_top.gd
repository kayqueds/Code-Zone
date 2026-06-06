extends Area2D

func _on_area_entered(area):
	print("ENCOSTOU:", area.name)

	var body = area.get_parent()

	if body == null:
		return

	if body.has_method("die") and not body.invulnerable:
		body.die()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
