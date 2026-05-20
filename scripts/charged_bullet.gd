extends Node2D

@onready var sprite = $AnimatedSprite2D

var speed = 500.0
var damage = 100

var direction = Vector2.RIGHT

func _ready():

	sprite.play("default")

	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):

	position += direction * speed * delta

func set_direction(new_direction):

	direction = new_direction

	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
