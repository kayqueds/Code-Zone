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
var max_jumps = 2
var jumps_left = 2
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
	add_to_group("player")
	spawn_position = global_position
	print("SPAWN SALVO:", spawn_position)
	add_to_group("players")
	life_bar = get_tree().current_scene.find_child("LifeBar1", true, false)
	update_life_bar()
	reset_jump_count()
func reset_jump_count() -> void:
	jumps_left = max_jumps

func try_jump(jump_force: float) -> void:
	if Input.is_action_just_pressed(input_jump) and jumps_left > 0 and is_alive:
		velocity.y = jump_force
		jumps_left -= 1
		som_pulo.play()
func toggle_invert():
	is_inverted = !is_inverted
	up_direction = Vector2.DOWN if is_inverted else Vector2.UP
func _physics_process(delta: float) -> void:
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		# Verifica se o nome do nó colidido é "Lava"
		if collider and collider.name == "Lava" and not invulnerable:
			die()
	

	if Input.is_action_just_pressed("invert_p1"):
		toggle_invert()

	invert_move(delta)
	move(delta)

	if is_alive:
		animations()

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
	
	try_jump(jump_velocity)
	
	move_and_slide()

	if is_on_floor():
		reset_jump_count()
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
	
	try_jump(-jump_velocity)
	
	move_and_slide()

	if is_on_floor() or is_on_ceiling():
		reset_jump_count()
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
	print("PLAYER 1 MORREU")
	if is_alive:
		is_alive = false
		
		# Atualiza a vida visualmente
		life = 0
		update_life_bar()
		
		# Toca a animação de morte
		anim.play("hurt")
		velocity = Vector2.ZERO
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)

		# ESPERA a animação terminar antes de sumir
		await anim.animation_finished
		
		# Faz o personagem sumir após a animação
		visible = false

		if get_parent().has_method("verificar_players"):
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
		
	if life <= 0:
		life_bar.frame = 5 # Supondo que 5 seja o frame de "zerado/morto" na sua animação
	elif life >= 80: 
		life_bar.frame = 0 
	elif life >= 60: 
		life_bar.frame = 1
	elif life >= 40: 
		life_bar.frame = 2
	elif life >= 20: 
		life_bar.frame = 3
	else: 
		life_bar.frame = 4
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
	invulnerable = true  # ATIVA A INVULNERABILIDADE
	life = max_life
	visible = true
	global_position = spawn_position
	velocity = Vector2.ZERO
	
	set_physics_process(true)
	$CollisionShape2D.set_deferred("disabled", false)
	
	update_life_bar()
	anim.play("idle")
	
	# PERÍODO DE GRAÇA: 1 segundo para o jogador sair da zona de perigo
	await get_tree().create_timer(1.0).timeout
	invulnerable = false
