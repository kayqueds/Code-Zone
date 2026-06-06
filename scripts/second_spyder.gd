extends CharacterBody2D

const SPEED = 80.0

var gravity = 980
var vida_aranha = 80
var is_alive = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_explosao: AudioStreamPlayer2D = $SomExplosao
@onready var hitbox = $Hitbox

@export var item_cura_scene: PackedScene
@export_range(0, 100) var chance_drop: float = 40.0

var player1
var player2

func _ready() -> void:

	player1 = get_tree().current_scene.find_child("Player", true, false)
	player2 = get_tree().current_scene.find_child("Player2", true, false)

	if not hitbox.is_connected("body_entered", _on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:

	if not is_alive:
		return

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	var alvo = pegar_jogador_mais_proximo()

	if alvo != null:

		var direcao = sign(alvo.global_position.x - global_position.x)

		velocity.x = direcao * SPEED

		if direcao > 0:
			anim.flip_h = false

		elif direcao < 0:
			anim.flip_h = true

		if anim.animation != "idle":
			anim.play("idle")

	else:
		velocity.x = 0

	move_and_slide()

func pegar_jogador_mais_proximo():

	var candidatos = []

	if player1 and player1.is_alive:
		candidatos.append(player1)

	if player2 and player2.is_alive:
		candidatos.append(player2)

	if candidatos.is_empty():
		return null

	var mais_proximo = candidatos[0]
	var menor_distancia = global_position.distance_to(mais_proximo.global_position)

	for jogador in candidatos:

		var distancia = global_position.distance_to(jogador.global_position)

		if distancia < menor_distancia:
			menor_distancia = distancia
			mais_proximo = jogador

	return mais_proximo

# DANO AO TOCAR NO JOGADOR
func _on_hitbox_body_entered(body):

	if not is_alive:
		return

	if body.has_method("receber_dano"):
		body.receber_dano(20)

func receber_dano(quantidade: int) -> void:

	if not is_alive:
		return

	vida_aranha -= quantidade

	modulate = Color.RED

	await get_tree().create_timer(0.1).timeout

	modulate = Color.WHITE

	if vida_aranha <= 0:
		die()

func die():

	if not is_alive:
		return

	is_alive = false

	velocity = Vector2.ZERO

	$CollisionShape2D.set_deferred("disabled", true)

	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)

	som_explosao.play()

	anim.play("death")

	# espera só a animação
	await anim.animation_finished

	calcular_drop()

	queue_free()
	
func calcular_drop():

	if item_cura_scene == null:
		return

	var numero_sorteado = randf() * 100.0

	if numero_sorteado <= chance_drop:

		var item_instanciado = item_cura_scene.instantiate()

		get_parent().call_deferred("add_child", item_instanciado)

		item_instanciado.global_position = global_position
