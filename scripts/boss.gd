extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

@export var max_health := 30
var health := max_health

func take_damage(amount := 1):
	print("BOSS RECEBEU DANO:", amount)
	health -= amount
	print("VIDA DO BOSS:", health)
	anim.play("hit")

	if health <= 0:
		queue_free()
	else:
		await anim.animation_finished
		anim.play("idle")

func die():
	queue_free()
