extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 450.0
var damage = 40
var direction = Vector2.RIGHT

func _ready():

	scale = Vector2(2, 2)

	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):

	position += direction * speed * delta

func set_direction(new_direction):

	direction = new_direction

	sprite.flip_h = direction.x < 0

func _on_body_entered(body):

	if body.has_method("take_damage"):

		body.take_damage(damage)

		queue_free()

func _on_area_entered(area: Area2D) -> void:

	if area.get_parent().has_method("take_damage"):

		area.get_parent().take_damage(damage)

		queue_free()
