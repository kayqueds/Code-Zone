extends CharacterBody2D

const speed = 100.0
const gravity = 900.0

@onready var anim = $AnimatedSprite2D
@export var health = 50
var can_attack = true

func _physics_process(delta):

	move(delta)

func move(delta):

	# gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# seguir player
	follow_player()

	# animações
	animations()

	move_and_slide()

func follow_player():

	var players = get_tree().get_nodes_in_group("player")

	if players.size() == 0:
		return

	var closest_player = null
	var closest_distance = INF

	for p in players:

		var distance = global_position.distance_to(p.global_position)

		if distance < closest_distance:

			closest_distance = distance
			closest_player = p

	if closest_player != null:

		var direction = closest_player.global_position - global_position

		velocity.x = direction.normalized().x * speed

		
			
func animations():

	if velocity.x != 0:
		anim.play("run")
	else:
		anim.play("idle")

	# virar sprite
	if velocity.x > 0:
		anim.flip_h = false

	if velocity.x < 0:
		anim.flip_h = true

func take_damage(damage):

	health -= damage

	print(name, " VIDA:", health)

	if health <= 0:
		die()

func die():

	print(name, " MORREU")

	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_attack:

		can_attack = false

		body.take_damage(10, global_position)

		await get_tree().create_timer(1.0).timeout

		can_attack = true
		
	pass
