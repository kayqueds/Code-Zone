extends Area2D

@export var speed := 500.0
@export var damage := 20

var direction := Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta


func set_direction(dir: Vector2):
	direction = dir


func _on_body_entered(body):
	print(body.name)
	if body.has_method("receber_dano"):
		body.receber_dano(50)


	queue_free()
