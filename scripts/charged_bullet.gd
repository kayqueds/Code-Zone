extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 400.0
var damage = 40
var direction = Vector2.RIGHT

func _ready():

	add_to_group("bullets")

	await get_tree().create_timer(5.0).timeout

	queue_free()

func _physics_process(delta):

	global_position += direction * speed * delta

func set_direction(new_direction):

	direction = new_direction.normalized()

	sprite.flip_h = direction.x < 0

func _on_body_entered(body):

	# NÃO acertar player
	if body.is_in_group("player"):
		return

	# acertar inimigos
	if body.has_method("take_damage"):

		body.take_damage(damage)

		queue_free()
