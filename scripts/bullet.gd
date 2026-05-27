extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 600.0
var damage = 10
var direction = Vector2.ZERO

func _ready():

	await get_tree().create_timer(0.2).timeout
	queue_free()

func _physics_process(delta):

	position += direction * speed * delta

func set_direction(new_direction):

	direction = new_direction

	sprite.flip_h = direction.x < 0

func _on_body_entered(body):

	if body.is_in_group("player"):
		return

	if body.has_method("take_damage"):

		body.take_damage(damage)
	elif body.has_method("receber_dano"):
		body.receber_dano(damage)	

		queue_free()
