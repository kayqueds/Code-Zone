extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 600.0
var damage = 10
var direction = Vector2.RIGHT

func _ready():

	await get_tree().create_timer(3.0).timeout
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

	print("BATEU EM AREA:", area.name)

	var boss = area.owner

	if boss != null and boss.has_method("take_damage"):

		print("CHAMANDO DANO NO BOSS")

		boss.take_damage(damage)

		queue_free()
