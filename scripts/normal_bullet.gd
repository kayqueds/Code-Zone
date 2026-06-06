extends Node

@export var bullet_scene: PackedScene
@onready var gun = get_parent()

func disparar(direction: Vector2) -> void:
	if bullet_scene == null: return
	var player = gun.get_parent()
	
	var bullet = bullet_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.global_position = player.gun_point.global_position
	bullet.set_direction(direction)
	
	player.som_tiro.play()
