extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var direction = 1
var damage = 20

# Variáveis
var distancia_percorrida = 0
var alcance_maximo = 400

func _process(delta: float) -> void:
	var movimento = speed * delta * direction
	position.x += movimento
	
	# distância
	distancia_percorrida += abs(movimento)
	
	# Se atingir o limite, destrói o projétil
	if distancia_percorrida >= alcance_maximo:
		queue_free()

func set_direction(skeleton_direction):
	direction = skeleton_direction
	anim.flip_h = direction < 0

func _on_self_destruct_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:

	if body.has_method("receber_dano"):
		body.receber_dano(damage)

	queue_free()
