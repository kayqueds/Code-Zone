extends CharacterBody2D

const SPEED = 0.0
var gravity = 980
var vida_inimigo = 80
var is_alive = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_explosao: AudioStreamPlayer2D = $SomExplosao
@onready var hitbox = $Hitbox
@onready var attack_timer = $ShootTimer

@export var projectile_scene: PackedScene
@export var item_cura_scene: PackedScene
@export_range(0, 100) var chance_drop: float = 40.0

var player1
var player2

func _ready() -> void:
	player1 = get_tree().current_scene.find_child("Player", true, false)
	player2 = get_tree().current_scene.find_child("Player2", true, false)

	if not hitbox.is_connected("body_entered", _on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Configura o timer de ataque (ex: dispara a cada 2 segundos)
	attack_timer.wait_time = 2.0
	attack_timer.timeout.connect(_shoot)
	attack_timer.start()

func _physics_process(delta: float) -> void:
	if not is_alive: return

	# Gravidade básica para se manter no chão
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = 0

	var alvo = pegar_jogador_mais_proximo()
	if alvo != null:
		# Apenas vira para o jogador
		var direcao = sign(alvo.global_position.x - global_position.x)
		anim.flip_h = (direcao < 0)

	move_and_slide()

func _shoot():
	if not is_alive or projectile_scene == null: return
	
	var alvo = pegar_jogador_mais_proximo()
	if alvo:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = global_position
		
		# Aqui está o ponto chave: usar a mesma lógica de direção que o seu projétil espera
		var dir = -1 if anim.flip_h else 1
		proj.set_direction(dir) # Chama a função que você definiu no script do projétil
func pegar_jogador_mais_proximo():
	var candidatos = [player1, player2]
	var mais_proximo = null
	var menor_distancia = INF

	for jogador in candidatos:
		if jogador and jogador.is_alive:
			var distancia = global_position.distance_to(jogador.global_position)
			if distancia < menor_distancia:
				menor_distancia = distancia
				mais_proximo = jogador
	return mais_proximo

func _on_hitbox_body_entered(body):
	if is_alive and body.has_method("receber_dano"):
		body.receber_dano(20)

func receber_dano(quantidade: int) -> void:
	if not is_alive: return
	vida_inimigo -= quantidade
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	if vida_inimigo <= 0:
		die()

func die():
	if not is_alive: return
	is_alive = false
	attack_timer.stop()
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	som_explosao.play()
	anim.play("death")
	await anim.animation_finished
	calcular_drop()
	queue_free()
	
func calcular_drop():
	if item_cura_scene == null: return
	if randf() * 100.0 <= chance_drop:
		var item = item_cura_scene.instantiate()
		get_parent().call_deferred("add_child", item)
		item.global_position = global_position
