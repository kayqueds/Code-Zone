extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var direction = 1

func _process(delta: float) -> void:
	position.x += speed * delta * direction

func set_direction(skeleton_direction):
	direction = skeleton_direction
	anim.flip_h = direction < 0

func _on_self_destruct_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	# Simplificado: Ignora outras áreas por enquanto
	pass

func _on_body_entered(body: Node2D) -> void:
	print("Colidiu com o corpo: ", body.name)
	
	# Verifica se o corpo é o seu Player
	if body.has_method("receber_dano"):
		body.receber_dano(20)
		queue_free() # Só some se acertar o Player
