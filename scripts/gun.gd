extends Node2D

@onready var bullet = preload("res://scene/bullet.tscn")

var direction = Vector2.RIGHT

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if get_parent().is_inverted:
		$"../GunPoint".position.y = 0.2
	else:
		$"../GunPoint".position.y = 3
	
	
	if get_parent().dir > 0:
		$"../GunPoint".position.x = 12
		direction = Vector2.RIGHT
		
	elif get_parent().dir < 0:
		$"../GunPoint".position.x = -1
		direction = Vector2.LEFT
	
	
	if Input.is_action_just_pressed("shoot_p1"):
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = $"../GunPoint".global_position
		
		get_parent().get_parent().add_child(new_bullet)
		
		new_bullet.set_direction(direction)
		
		
		
		
		
	pass
