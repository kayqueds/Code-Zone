extends CharacterBody2D

const SPEED = 100.0
const JUMP_FORCE = -300.0
var gravity = 980
var direction = 1
var vida_aranha = 80
@onready var wall_detector = $WallDetector
@onready var floor_detector = $FloorDetector
@onready var jump_timer = $Timer

func _ready() -> void:
	jump_timer.start(randf_range(1.0, 2.5)) # Inicia o primeiro ciclo

func _physics_process(delta: float) -> void:
	# 1. Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = SPEED * direction 
	
	
	if wall_detector.is_colliding() or not floor_detector.is_colliding():
		direction *= -1
		scale.x *= -1
		
	move_and_slide()


func _on_timer_timeout() -> void:
	if is_on_floor():
		velocity.y = JUMP_FORCE # Executa o pulo
		# Adicione aqui: anim.play("pulo")
	
	# Reinicia o tempo para o próximo pulo aleatório
	jump_timer.start(randf_range(1.0, 2.5))

# Dano
func _on_hitbox_body_entered(body: Node2D) -> void:
	
	if body.has_method("receber_dano"):
		body.receber_dano(20)

func receber_dano(quantidade: int) -> void:
	vida_aranha -= quantidade
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if vida_aranha <= 0:
		die()

func die():
	queue_free()
