extends CharacterBody2D
# mecanica base
var speed = 160.0
var jump_velocity = -300.0
var life: int = 100
var max_life: int = 100
var invulnerable: bool = false
var spawn_position: Vector2
var dir
var gravity = 980
var extra_jumps = 1
# animações
@onready var anim = $AnimatedSprite2D
@onready var gun_point = $GunPoint # Referência necessária para a Arma

# Nós de Áudio que já estão no seu Player
@onready var som_pulo: AudioStreamPlayer2D = $SomPulo
@onready var som_tiro: AudioStreamPlayer2D = $SomTiro
@onready var som_tiro_carregado: AudioStreamPlayer2D = $SomTiroCarregado
@onready var som_carregando: AudioStreamPlayer2D = $SomCarregando
@onready var som_dano: AudioStreamPlayer2D = $SomDano
@onready var som_cura: AudioStreamPlayer2D = $SomCura


var is_alive = true
@export var is_inverted = false
# movimentos
@export var input_left := "left_p1"
@export var input_right := "right_p1"
@export var input_jump := "jump_p1"

# barra de vida
var life_bar: AnimatedSprite2D = null

func _ready() -> void:
	spawn_position = global_position
	var spawn_position: Vector2
	life_bar = get_tree().current_scene.find_child("LifeBar1", true, false)
	update_life_bar()
	pass

func _physics_process(delta: float) -> void:
	set_gravity()
	
	invert_move(delta)
	move(delta)
	
	if is_alive:
		animations()

func set_gravity():
	if Input.is_action_just_pressed("inverter_gravidade"):
		is_inverted = !is_inverted
		
		# Ajusta o que a Godot considera "TETO" ou "CHÃO"
		up_direction = Vector2.DOWN if is_inverted else Vector2.UP

func move(delta):
	if is_inverted:
		return
	
	if is_alive:
		dir = Input.get_axis(input_left , input_right)
	
	if dir:
		velocity.x = dir * speed
	elif dir == 0:
		velocity.x = 0
	
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed(input_jump) and extra_jumps > 0 and is_alive:
		velocity.y = jump_velocity
		extra_jumps -= 1
		som_pulo.play() # Toca som de pulo normal
	
	if is_on_floor():
		extra_jumps = 1
	
	move_and_slide()

func invert_move(delta):
	if not is_inverted:
		return
	
	if is_alive:
		dir = Input.get_axis(input_left , input_right)
	
	if dir:
		velocity.x = dir * speed
	elif dir == 0:
		velocity.x = 0
	
	velocity.y += -gravity * delta
	
	if Input.is_action_just_pressed(input_jump) and extra_jumps > 0 and is_alive:
		velocity.y = -jump_velocity
		extra_jumps -= 1
		som_pulo.play() # Toca som de pulo invertido
	
	if is_on_ceiling():
		extra_jumps = 1
	
	move_and_slide()

func animations():
	anim.flip_v = is_inverted
	
	var esta_apoiado = is_on_floor() if not is_inverted else is_on_ceiling()
	
	if velocity.x != 0 and esta_apoiado:
		anim.play("walk")
	elif velocity.x == 0 and esta_apoiado:
		anim.play("idle")
	
	if not esta_apoiado:
		anim.play("jump")
	
	# Flip horizontal baseado na direção e ajusta o GunPoint
	if dir > 0:
		anim.flip_h = false
		gun_point.position.x = 12
	elif dir < 0:
		anim.flip_h = true
		gun_point.position.x = -12

# morte
func die():

	if is_alive:

		is_alive = false

		anim.play("hurt")

		velocity = Vector2.ZERO

		$CollisionShape2D.set_deferred("disabled", true)

		set_physics_process(false)

		await get_tree().create_timer(1.0).timeout

		visible = false

		get_parent().verificar_players()
		
# dano
func receber_dano(quantidade: int) -> void:
	if invulnerable or not is_alive: 
		return
		
	invulnerable = true
	life = clamp(life - quantidade, 0, max_life)
	print("Vida do ", name, ": ", life)
	update_life_bar()
	som_dano.play() # Toca som de dano
	
	modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	
	if life <= 0:
		die()
	else:
		await get_tree().create_timer(0.4).timeout
		invulnerable = false


# atualizar vida
func update_life_bar():
	if life_bar == null: 
		return
	if life >= 80: 
		life_bar.frame = 0    # Cheia
	elif life >= 60: 
		life_bar.frame = 1  # 3/4
	elif life >= 40: 
		life_bar.frame = 2  # Metade
	elif life >= 20: 
		life_bar.frame = 3  # Quase vazia
	else: 
		life_bar.frame = 4            # Crítica / Vazia

# cura
func curar(quantidade: int) -> bool:
	if not is_alive or life >= max_life:
		return false # Não curou porque está morto ou cheio
		
	life = clamp(life + quantidade, 0, max_life)
	print("Vida de ", name, " curada para: ", life)
	
	update_life_bar()
	
	if som_cura:
		som_cura.play() 
	
	modulate = Color.GREEN
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	
	return true # Avisa que a cura deu certo!

func respawn():

	is_alive = true

	invulnerable = false

	life = max_life

	visible = true

	# VOLTA PRO PONTO INICIAL
	global_position = spawn_position

	# ZERA MOVIMENTO
	velocity = Vector2.ZERO

	# REATIVA PROCESSOS
	set_physics_process(true)
	set_process(true)

	# REATIVA COLISÃO
	$CollisionShape2D.set_deferred("disabled", false)

	update_life_bar()

	anim.play("idle")
