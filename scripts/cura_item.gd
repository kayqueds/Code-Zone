extends Area2D

@export var quantidade_cura: int = 20
@export var sprite_textura: Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite_textura:
		sprite_2d.texture = sprite_textura

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var curou = await body.curar(quantidade_cura)
		
		if curou:
			queue_free()
