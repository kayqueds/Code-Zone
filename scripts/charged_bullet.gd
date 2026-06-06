extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 600.0
var damage = 40
var direction = Vector2.ZERO
var shooter = null

func _ready():
	# REMOVIDO: O timer que destruía o tiro em 0.2s
	pass 

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(new_direction):
	direction = new_direction
	sprite.flip_h = direction.x < 0
	
func set_shooter(player):
	shooter = player
	
func _on_body_entered(body):
	# Ignora o dono do disparo e qualquer coisa que seja "player"
	if body == shooter or body.is_in_group("player"):
		return
		
	# Aplica dano se o alvo tiver o método
	if body.has_method("take_damage"):
		body.take_damage(damage)
	elif body.has_method("receber_dano"):
		body.receber_dano(damage)	
	
	# Destrói o tiro após colidir com inimigo ou parede
	queue_free()
