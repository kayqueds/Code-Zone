extends CharacterBody2D

const speed = 300.0
const jump_force = -400.0
const gravity = 900

@export var input_left: String
@export var input_right: String
@export var input_jump: String
@export var input_attack: String

# vida do player
@export var health = 100

@onready var attack_area = $AttackArea

var taking_damage = false

func _physics_process(delta: float) -> void:
	move(delta)
	attack()

func move(delta):

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimento
	var direction = Input.get_axis(input_left, input_right)

	if not taking_damage:
		velocity.x = direction * speed

	# Pulo
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

func attack():

	if Input.is_action_just_pressed(input_attack):

		print(name, "ATACOU")

		for body in attack_area.get_overlapping_bodies():

			if body != self and body.has_method("take_damage"):

				body.take_damage(10)

func take_damage(damage, enemy_position = Vector2.ZERO):

	health -= damage

	print(name, " VIDA:", health)

	taking_damage = true

	# knockback
	var direction = global_position - enemy_position

	velocity.x = direction.normalized().x * 500
	velocity.y = -200

	await get_tree().create_timer(0.2).timeout

	taking_damage = false

	if health <= 0:
		die()

func die():

	print(name, " MORREU")

	queue_free()
