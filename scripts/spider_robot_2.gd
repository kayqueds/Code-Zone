extends CharacterBody2D
enum BossState {
	IDLE,
	ATTACK_JUMP,
	FIRE_PATTERN,
	RETURN,
	RUN_ATTACK
}

const RUN_SPEED = 700.0
const MAGIC_SCENE = preload("res://scene/Magic.tscn")
const SPEED = 100.0
const JUMP_FORCE = -300.0
var attack_count := 0
var state = BossState.IDLE
var dropped_50 := false
var dropped_25 := false
var initial_position: Vector2
var attack_position: Vector2
var gravity = 980
var direction = 0
var vida_aranha = 1500
var is_alive = true # Flag para controlar o estado
var fogo_ativo = false
var can_attack = true

@onready var lifebar = get_node("../BossLifeBar")
@onready var cutscene_music = $CutsceneMusic
@onready var wall_detector = $WallDetector
@onready var floor_detector = $FloorDetector
#@onready var jump_timer = $Timer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D # Referência ao seu AnimatedSprite
@onready var player = get_tree().get_first_node_in_group("player")
@onready var player2 = get_tree().get_first_node_in_group("player2")
const CURA_SCENE = preload("res://entities/CuraItem.tscn")
@export var item_cura_scene: PackedScene
@export_range(0, 100) var chance_drop: float = 40.0
@onready var fire_attacks = [
	$"../FireAttack2",
	$"../FireAttack3",
	$"../FireAttack4",
	$"../FireAttack5",
	$"../FireAttack6",
	$"../FireAttack7",
	$"../FireAttack8",
	$"../FireAttack9",
	$"../FireAttack10"
]
# som
@onready var som_explosao: AudioStreamPlayer2D = $SomExplosao


func _ready() -> void:
	cutscene_music.play()
	initial_position = global_position
	start_boss_loop()

	
func start_boss_loop():

	while is_alive:

		await start_attack()

		# pausa entre ataques
		await get_tree().create_timer(1.5).timeout
	
func testar_fogo():

	while true:

		# MOSTRA + ATIVA
		for fire in fire_attacks:
			if fire:
				fire.show()
				fire.monitoring = true

				var anim = fire.get_node_or_null("AnimatedSprite2D")
				if anim:
					anim.play()

		print("FOGO LIGADO")

		await get_tree().create_timer(2.0).timeout

		# ESCONDE + DESATIVA
		for fire in fire_attacks:
			if fire:
				fire.hide()
				fire.monitoring = false


		print("FOGO DESLIGADO")

		await get_tree().create_timer(2.0).timeout
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	velocity.y = clamp(velocity.y, -999, 500)
	if not is_alive:
		return

	# 1. Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = SPEED * direction 
	
	if wall_detector.is_colliding():
		print("PAREDE")

	if not floor_detector.is_colliding():
		print("CHAO")
		direction *= -1
		scale.x *= -1
		
	move_and_slide()
func start_attack():
	if state != BossState.IDLE:
		return

	if attack_count >= 3:
		state = BossState.RUN_ATTACK
		run_attack()
	else:
		state = BossState.ATTACK_JUMP
		attack_sequence()
	
func attack_sequence() -> void:


	# 🔥 ativa fogo primeiro
	await fire_pattern()

	# depois o boss reage com pulo + magia
	$AnimatedSprite2D.play("attack_jump")
	await get_tree().create_timer(0.5).timeout

	global_position.y -= 80

	spawn_magic()

	state = BossState.RETURN
	await return_to_start()

	state = BossState.IDLE
	
	attack_count += 1
func run_attack() -> void:

	anim.play("walk")

	var direction = -1  # começa indo pra esquerda

	for i in range(2): # vai e volta

		# corre
		for t in range(60): # tempo da corrida
			velocity.x = SPEED * direction
			move_and_slide()
			await get_tree().process_frame

		# vira direção
		direction *= -1
		scale.x *= -1

	# volta ao normal
	velocity.x = 0
	anim.play("idle")

	attack_count = 0
	state = BossState.IDLE
	
func spawn_magic():
	var magic = MAGIC_SCENE.instantiate()
	get_tree().current_scene.add_child(magic)

	magic.global_position = global_position

	var target = get_closest_player().global_position
	magic.direction = (target - global_position).normalized()
func get_closest_player():
	var players = get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return null

	var closest = null
	var min_dist = INF

	for p in players:
		var d = global_position.distance_to(p.global_position)
		if d < min_dist:
			min_dist = d
			closest = p

	return closest
func update_life_bar():

	var max_hp = 1000.0
	var frames = 29

	var percent = vida_aranha / max_hp

	var frame_index = int((1.0 - percent) * (frames - 1))

	frame_index = clamp(frame_index, 0, frames - 1)

	lifebar.frame = frame_index
func fire_pattern() -> void:


	# 🔥 LIGA O FOGO
	for fire in fire_attacks:
		if fire == null:
			continue

		fire.show()
		fire.monitoring = true

		var anim = fire.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play()

	await get_tree().create_timer(2.0).timeout

	# 💥 DESLIGA O FOGO
	for fire in fire_attacks:
		if fire == null:
			continue

		fire.hide()
		fire.monitoring = false
func return_to_start() -> void:

	var t := 0.0
	var duration := 0.6

	var start_pos = global_position

	while t < duration:
		t += get_process_delta_time()

		global_position = start_pos.lerp(initial_position, t / duration)
		await get_tree().process_frame

func _on_timer_timeout() -> void:
	if is_alive and is_on_floor():
		velocity.y = JUMP_FORCE
		# Se tiver animação de pulo: anim.play("jump")
	

# Dano
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_alive and body.has_method("receber_dano"):
		body.receber_dano(20)

func receber_dano(quantidade: int) -> void:
	if not is_alive: return
	
	vida_aranha -= quantidade

	update_life_bar()
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	check_item_drops()
	if vida_aranha <= 0:
		die()
func check_item_drops():

	var max_hp = 1500.0

	# 🔥 50%
	if not dropped_50 and vida_aranha <= max_hp * 0.5:
		dropped_50 = true
		spawn_cura_items(3)

	# 🔥 25%
	if not dropped_25 and vida_aranha <= max_hp * 0.25:
		dropped_25 = true
		spawn_cura_items(3)
		
func spawn_cura_items(amount: int):

	for i in range(amount):
		var item = CURA_SCENE.instantiate()
		get_tree().current_scene.add_child(item)

		# espalha os itens ao redor do boss
		var offset = Vector2(
			randf_range(-80, 80),
			randf_range(-20, 20)
		)
		var top_y = get_viewport().get_visible_rect().position.y + 15
		item.global_position = Vector2(randf_range(50, 250), top_y)

func die():
	is_alive = false # Impede que ele continue andando ou pulando

	# Desativa a colisão física para não atrapalhar o jogo
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set
	som_explosao.play()
	anim.play("death")
	# esperar animação
	
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scene/you_win.tscn")
	queue_free()

# drop de item
func calcular_drop():
	if item_cura_scene == null:
		return
	var numero_sorteado = randf() * 100.0
	if numero_sorteado <= chance_drop:
		var item_instanciado = item_cura_scene.instantiate()
		get_parent().call_deferred("add_child", item_instanciado)
		item_instanciado.global_position = global_position
