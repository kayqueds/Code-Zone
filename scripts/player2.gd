extends CharacterBody2D

# mecanica base
var speed = 160.0
var jump_velocity = -300.0
var life: int = 100
var max_life: int = 100
var invulnerable: bool = false
var spawn_position: Vector2

var dir: float = 0.0
var gravity = 980
var max_jumps = 2
var jumps_left = 2

# animações
@onready var anim = $AnimatedSprite2D

# Nós de Áudio que já estão no seu Player
@onready var som_pulo: AudioStreamPlayer2D = $SomPulo
@onready var som_dano: AudioStreamPlayer2D = $SomDano
@onready var som_cura: AudioStreamPlayer2D = $SomCura


var is_alive = true
var is_punching = false

@export var is_inverted = false

# movimentos
@export var input_left := "left_p2"
@export var input_right := "right_p2"
@export var input_jump := "jump_p2"
@export var input_punch := "ataque_p2"


# hitbox
@onready var hitbox_ataque = $HitBoxAtaque/CollisionShape2D

# barra de vida
var life_bar: AnimatedSprite2D = null

func _ready() -> void:
	spawn_position = global_position
	hitbox_ataque.disabled = true
	if not hitbox_ataque.get_parent().is_connected("body_entered", _on_hitbox_ataque_body_entered):
		hitbox_ataque.get_parent().body_entered.connect(_on_hitbox_ataque_body_entered)
	
	life_bar = get_tree().current_scene.find_child("LifeBar2", true, false)
	update_life_bar()
	reset_jump_count()

func reset_jump_count() -> void:
	jumps_left = max_jumps

func try_jump(jump_force: float) -> void:
	if Input.is_action_just_pressed(input_jump) and jumps_left > 0 and is_alive:
		velocity.y = jump_force
		jumps_left -= 1
		som_pulo.play()

# Lógica de Dano do Soco
func _on_hitbox_ataque_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(20)
	elif body.has_method("receber_dano"):
		body.receber_dano(20)

func _input(event):
	if event.is_action_pressed(input_punch):
		if is_alive and not is_punching:
			is_punching = true
			anim.play("puch")
			hitbox_ataque.disabled = false
			await get_tree().create_timer(0.3).timeout 
			hitbox_ataque.disabled = true
			is_punching = false

func _physics_process(delta: float) -> void:
	if dir < 0:
		hitbox_ataque.position.x = -20 # Ajuste o valor para a esquerda
	# Se estiver virado para a direita (direção 1)
	elif dir > 0:
		hitbox_ataque.position.x = 20
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
	
	if is_punching:
		return
	
	var esta_apoiado = is_on_floor() if not is_inverted else is_on_ceiling()
	
	if not esta_apoiado:
		anim.play("jump")
	elif velocity.x != 0:
		anim.play("walk")
	else:
		anim.play("idle")
	
	if dir != 0:
		anim.flip_h = (dir < 0)
# morte
func die():
	if is_alive:
		is_alive = false
		velocity = Vector2.ZERO
		anim.play("hurt")
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

# curar
func curar(quantidade: int) -> bool:
	if not is_alive or life >= max_life:
		return false
		
	life = clamp(life + quantidade, 0, max_life)
	print("Vida de ", name, " curada para: ", life)
	
	update_life_bar()
	
	if som_cura:
		som_cura.play() 
	
	modulate = Color.GREEN
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	
	return true

func respawn():

	global_position = spawn_position
	velocity = Vector2.ZERO

	is_alive = true
	invulnerable = false
	life = max_life

	visible = true

	set_physics_process(true)
	set_process(true)

	$CollisionShape2D.disabled = false

	update_life_bar()

	anim.play("idle")
