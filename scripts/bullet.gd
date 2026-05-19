extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 600.0
var direction = Vector2.RIGHT

func _ready():

	if direction.x < 0:
		sprite.flip_h = true

	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta):

	position += direction * speed * delta

func set_direction(new_direction):

	direction = new_direction

	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
