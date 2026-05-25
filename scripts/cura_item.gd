extends Area2D

@export var quantidade_cura: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var curou = await body.curar(quantidade_cura)
		
		if curou:
			queue_free()
