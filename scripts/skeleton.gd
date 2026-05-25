extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	hurt
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

func walk_state(_delta):

	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0

	if wall_detector.is_colliding():
		flip_enemy()

	if not ground_detector.is_colliding():
		flip_enemy()

	if player_detector.is_colliding():
		go_to_attack_state()

func attack_state(_delta):

	if anim.frame == 2 and can_throw:

		throw_bone()
		can_throw = false

func hurt_state(_delta):
	pass

func take_damage(damage):

	if invulnerable:
		return

	invulnerable = true

	health -= damage

	print("Vida inimigo:", health)

	# efeito visual dano
	modulate = Color.RED

	# knockback
	velocity.x = -direction * 80

	if health <= 0:

		die()
		return

	go_to_hurt_state()

	await get_tree().create_timer(0.15).timeout

	modulate = Color.WHITE

	await get_tree().create_timer(0.25).timeout

	invulnerable = false

func die():
	# Chama a função que calcula a probabilidade de dropar o item
	calcular_drop()
	queue_free()

func calcular_drop():
	# Garante que colocamos a cena do item no Inspector
	if item_cura_scene == null:
		return

	# randf() gera um número entre 0 e 1. Multiplicamos por 100 para virar porcentagem (0 a 100)
	var numero_sorteado = randf() * 100.0
	
	print("Inimigo morreu! Número sorteado para o drop: ", numero_sorteado)

	# Se o número sorteado for menor ou igual à nossa chance, o item spawna!
	if numero_sorteado <= chance_drop:
		var item_instanciado = item_cura_scene.instantiate()
		
		# Adiciona o item na fase (como irmão do esqueleto, para não sumir junto com ele)
		get_parent().add_child(item_instanciado)
		
		# Define a posição do item exatamente onde o esqueleto morreu
		item_instanciado.global_position = global_position
		print("Item dropado com sucesso!")



func throw_bone():

	var new_bone = SPINNING_BONE.instantiate()

	add_sibling(new_bone)

	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(direction)

func flip_enemy():

	scale.x *= -1
	direction *= -1

func _on_animated_sprite_2d_animation_finished() -> void:

	if anim.animation == "attack":

		go_to_walk_state()

	elif anim.animation == "hurt":

		go_to_walk_state()
		
func _on_hitbox_body_entered(body):

	if body.is_in_group("player"):

		body.take_damage(20)
