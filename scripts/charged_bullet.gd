extends Area2D

@onready var sprite = $AnimatedSprite2D

var speed = 500.0       # Velocidade do tirão
var damage = 35         # Dano do tirão
var direction = Vector2.ZERO

func _ready():
	# Tempo que o tirão fica na tela antes de sumir sozinho
	await get_tree().create_timer(1.2).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

# ESSA É A FUNÇÃO QUE ESTAVA FALTANDO:
func set_direction(new_direction):
	direction = new_direction
	if sprite:
		sprite.flip_h = direction.x < 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		return

	# Se atingir um inimigo que herda o método de dano
	if body.has_method("take_damage"):
		body.take_damage(damage)
	elif body.has_method("receber_dano"):
		body.receber_dano(damage)
		
	# Se bater em paredes ou chão da fase, o tiro some
	if body is TileMapLayer or body is StaticBody2D: 
		queue_free()
