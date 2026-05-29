extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	hurt,
	dead # Adicionamos o estado de morto
}

const SPINNING_BONE = preload("res://entities/spinning_bone.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

@export var item_cura_scene: PackedScene 
@export_range(0, 100) var chance_drop: float = 40.0

#som
@onready var som_explosao: AudioStreamPlayer2D = $SomExplosao


const SPEED = 20.0
@export var max_health = 50
var health = 50
var status: SkeletonState
var direction = 1
var can_throw = true
var invulnerable = false

func _ready() -> void:
	health = max_health
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Se estiver morto, para tudo aqui!
	if status == SkeletonState.dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.hurt:
			hurt_state(delta)

	move_and_slide()

# --- Funções de Estado ---
func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")

func go_to_attack_state():
	status = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true

func go_to_hurt_state():
	status = SkeletonState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO

func go_to_death_state():
	status = SkeletonState.dead
	velocity = Vector2.ZERO
	
	# Desativa colisões
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	anim.play("death") # Certifique-se de ter a animação "death" no AnimatedSprite2D
	await anim.animation_finished
	
	calcular_drop()
	queue_free()

# --- Lógica de Estado ---
func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0

	if wall_detector.is_colliding(): flip_enemy()
	if not ground_detector.is_colliding(): flip_enemy()
	if player_detector.is_colliding(): go_to_attack_state()

func attack_state(_delta):
	if anim.frame == 2 and can_throw:
		throw_bone()
		can_throw = false

func hurt_state(_delta):
	pass

# --- Dano e Morte ---
func take_damage(damage):
	if invulnerable or status == SkeletonState.dead:
		return

	invulnerable = true
	health -= damage
	modulate = Color.RED
	velocity.x = -direction * 80

	if health <= 0:
		som_explosao.play()
		go_to_death_state()
		return

	go_to_hurt_state()
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	await get_tree().create_timer(0.25).timeout
	invulnerable = false

func calcular_drop():
	if item_cura_scene == null: return
	var numero_sorteado = randf() * 100.0
	if numero_sorteado <= chance_drop:
		var item_instanciado = item_cura_scene.instantiate()
		get_parent().call_deferred("add_child", item_instanciado)
		item_instanciado.global_position = global_position

func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(direction)

func flip_enemy():
	scale.x *= -1
	direction *= -1

func _on_animated_sprite_2d_animation_finished() -> void:
	if status == SkeletonState.dead: return # Não volta se estiver morto

	if anim.animation == "attack":
		go_to_walk_state()
	elif anim.animation == "hurt":
		go_to_walk_state()
