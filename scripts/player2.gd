extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	wall,
	swimming,
	hurt
}

@onready var anim = $AnimatedSprite2D
@onready var reload_timer = $ReloadTimer
@onready var left_wall_detector = $LeftWallDetector
@onready var right_wall_detector = $RightWallDetector

# Vida e Interface (HUD)
@export var max_life := 100
@export var life_bar_path : NodePath
@onready var life_bar = get_node(life_bar_path)
var life := 100
var invulnerable = false

# Movimentação e Física
@export var max_speed = 180.0
@export var acceleration = 400
@export var deceleration = 400
@export var wall_acceleration = 40
@export var wall_jump_velocity = 240
@export var water_max_speed = 100
@export var water_acceleration = 200
@export var water_jump_force = -100

#sons player 2
@onready var som_pulo: AudioStreamPlayer2D = $SomPulo
@onready var som_curar: AudioStreamPlayer2D = $SomCura
@onready var som_dano: AudioStreamPlayer2D = $SomDano

# INPUTS PLAYER 2
@export var input_left := "left_p2"
@export var input_right := "right_p2"
@export var input_jump := "jump_p2"

const JUMP_VELOCITY = -300.0
var jump_count = 0
@export var max_jump_count = 2

var direction = 0
var facing_direction = 1
var status : PlayerState

func _ready():
	# Mantém no grupo comum para inimigos e itens universais funcionarem perfeitamente
	add_to_group("player")
	go_to_idle_state()
	update_life_bar()

func _physics_process(delta):
	match status:
		PlayerState.idle: idle_state(delta)
		PlayerState.walk: walk_state(delta)
		PlayerState.jump: jump_state(delta)
		PlayerState.fall: fall_state(delta)
		PlayerState.wall: wall_state(delta)
		PlayerState.swimming: swimming_state(delta)
		PlayerState.hurt: hurt_state(delta)

	move_and_slide()
	handle_shoot()

# ==================== ESTADOS ====================
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	som_pulo.play()

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_wall_state():
	status = PlayerState.wall
	anim.play("wall")
	velocity = Vector2.ZERO
	jump_count = 0

func go_to_swimming_state():
	status = PlayerState.swimming
	anim.play("swimming")
	velocity.y = min(velocity.y, 150)

func go_to_hurt_state():
	if status == PlayerState.hurt:
		return
	status = PlayerState.hurt
	anim.play("hurt")
	velocity.x = 0
	reload_timer.start()

# ==================== COMPORTAMENTOS DOS ESTADOS ====================
func idle_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed(input_jump):
		go_to_jump_state()
		return

func walk_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed(input_jump):
		go_to_jump_state()
		return
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()

func jump_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed(input_jump) and can_jump():
		go_to_jump_state()
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed(input_jump) and can_jump():
		go_to_jump_state()
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) and is_on_wall():
		go_to_wall_state()

func wall_state(delta):
	velocity.y += wall_acceleration * delta
	if left_wall_detector.is_colliding():
		anim.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()

	if is_on_floor():
		go_to_idle_state()
	if Input.is_action_just_pressed(input_jump):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()

func swimming_state(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, water_max_speed * direction, water_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)

	velocity.y += water_acceleration * delta
	velocity.y = min(velocity.y, water_max_speed)
	if Input.is_action_just_pressed(input_jump):
		velocity.y = water_jump_force

func hurt_state(delta):
	apply_gravity(delta)

# ==================== MECÂNICAS GERAIS ====================
func move(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func update_direction():
	direction = Input.get_axis(input_left, input_right)
	if direction < 0:

		facing_direction = -1
		anim.flip_h = true
		gun_point.position.x = -12

	elif direction > 0:

		facing_direction = 1
		anim.flip_h = false
		gun_point.position.x = 12

func can_jump() -> bool:
	return jump_count < max_jump_count

func set_small_collider():

	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3

func set_large_collider():

	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0

	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func _on_hitbox_area_entered(area: Area2D) -> void:

	if area.is_in_group("Enemies"):
		hit_enemy(area)

	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func _on_hitbox_body_entered(body: Node2D) -> void:

	if body.is_in_group("LethalArea"):
		go_to_hurt_state()

	elif body.is_in_group("Water"):
		go_to_swimming_state()

func hit_enemy(area: Area2D):

	if velocity.y > 0:

		area.get_parent().take_damage()

		go_to_jump_state()

	else:

		go_to_hurt_state()

func hit_lethal_area():
# ==================== COMBATE E SISTEMAS ====================
func take_damage(damage_amount):
	if invulnerable:
		return
	invulnerable = true
	life -= damage_amount
	life = clamp(life, 0, max_life)
	update_life_bar()
	som_dano.play()
	print("Vida P2:", life)

	modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	invulnerable = false

	if life <= 0:
		die()

func update_life_bar():
	if life_bar == null:
		return
	if life >= 80: life_bar.frame = 0
	elif life >= 60: life_bar.frame = 1
	elif life >= 40: life_bar.frame = 2
	elif life >= 20: life_bar.frame = 3
	else: life_bar.frame = 4

func curar(quantidade_cura) -> bool:
	if life >= max_life:
		print("Vida já está cheia, item não coletado.")
		return false
	
	life += quantidade_cura
	life = clamp(life, 0, max_life)
	update_life_bar()
	som_curar.play()
	print(name, " curado! Vida atual: ", life)
	
	
	# O intervalo do efeito verde roda aqui com segurança!
	var antiga_cor = modulate
	modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	modulate = antiga_cor
	
	return true
func die():
	go_to_hurt_state()

func _on_reload_timer_timeout():
	get_tree().reload_current_scene()

func _on_hitbox_body_exited(body: Node2D) -> void:

	if body.is_in_group("Water"):

		jump_count = 0

		go_to_jump_state()

# =========================
# TIRO PLAYER 2
# =========================

func handle_shoot():

	if Input.is_action_just_pressed("shoot_p2"):

		is_charging = true
		charged_shot_ready = false

		charge_timer.start()

	if Input.is_action_just_released("shoot_p2"):

		if charged_shot_ready:
			shoot_charged()
		else:
			shoot_normal()

		is_charging = false

func shoot_normal():

	if bullet_scene == null:
		return
		
	shoot_sound.play()

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = gun_point.global_position

	if facing_direction < 0:
		bullet.set_direction(Vector2.LEFT)
	else:
		bullet.set_direction(Vector2.RIGHT)

func shoot_charged():

	if charged_bullet_scene == null:
		return

	var bullet = charged_bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = gun_point.global_position

	if facing_direction < 0:
		bullet.set_direction(Vector2.LEFT)
	else:
		bullet.set_direction(Vector2.RIGHT)

func _on_charge_timer_timeout():

	if is_charging:
		charged_shot_ready = true
