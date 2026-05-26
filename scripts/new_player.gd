extends CharacterBody2D

var speed = 160.0
var jump_velocity = -300.0
var life: int = 100
var max_life: int = 100
var invulnerable: bool = false

var dir

var gravity = 980

var extra_jumps = 1

@onready var anim = $AnimatedSprite2D

var is_alive = true

@export var is_inverted = false

@export var input_left := "left_p1"
@export var input_right := "right_p1"
@export var input_jump := "jump_p1"

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	print(is_inverted)
	
	set_gravity()
	
	
	invert_move(delta)
	move(delta)
	
	
	if is_alive:
		animations()
	
	pass

func set_gravity():
	
	if Input.is_action_just_pressed("inverter_gravidade") and not is_inverted:
		is_inverted = true
	elif Input.is_action_just_pressed("inverter_gravidade") and is_inverted:
		is_inverted = false
	
	pass


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
	
	if is_on_floor():
		extra_jumps = 1
	
	move_and_slide()
	
	pass

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
	
	if is_on_ceiling():
		extra_jumps = 1
	
	move_and_slide()
	
	pass

func animations():
	anim.flip_v = is_inverted
	

	var esta_apoiado = is_on_floor() if not is_inverted else is_on_ceiling()
	
	if velocity.x != 0 and esta_apoiado:
		anim.play("walk")
	elif velocity.x == 0 and esta_apoiado:
		anim.play("idle")
	
	if not esta_apoiado:
		anim.play("jump")
	
	# Flip horizontal baseado na direção
	if dir > 0:
		anim.flip_h = false
	elif dir < 0:
		anim.flip_h = true

# morte
func die():
	if is_alive:
		is_alive = false
		anim.play("hurt")
		velocity.y = jump_velocity - 100 
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()


# dano
func receber_dano(quantidade: int) -> void:
	if invulnerable or not is_alive: 
		return
		
	invulnerable = true
	life = clamp(life - quantidade, 0, max_life)
	print("Vida do ", name, ": ", life) # Avisa no console
	
	# Feedback Visual: Pisca em vermelho
	modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	
	if life <= 0:
		die()
	else:
		await get_tree().create_timer(0.4).timeout
		invulnerable = false
		
		
