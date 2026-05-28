extends CharacterBody2D

const SPEED = 100.0
const JUMP_FORCE = -300.0
var gravity = 980
var direction = 1
var vida_aranha = 80
var is_alive = true # Flag para controlar o estado

@onready var wall_detector = $WallDetector
@onready var floor_detector = $FloorDetector
@onready var jump_timer = $Timer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D # Referência ao seu AnimatedSprite

func _ready() -> void:
	jump_timer.start(randf_range(1.0, 2.5))

func _physics_process(delta: float) -> void:
	# Só processa movimento se estiver vivo
	if not is_alive:
		return

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
	if is_alive and is_on_floor():
		velocity.y = JUMP_FORCE
		# Se tiver animação de pulo: anim.play("jump")
	
	if is_alive:
		jump_timer.start(randf_range(1.0, 2.5))

# Dano
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_alive and body.has_method("receber_dano"):
		body.receber_dano(20)

func receber_dano(quantidade: int) -> void:
	if not is_alive: return
	
	vida_aranha -= quantidade
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if vida_aranha <= 0:
		die()

func die():
	is_alive = false # Impede que ele continue andando ou pulando
	jump_timer.stop()
	# Desativa a colisão física para não atrapalhar o jogo
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set
	anim.play("death")
	
	# esperar animação
	await anim.animation_finished
	queue_free()
