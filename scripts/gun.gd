extends Node2D

@export var bullet_scene: PackedScene
@export var charged_bullet_scene: PackedScene

@onready var player = get_parent()

var tempo_carregando : float = 0.0
const TEMPO_CARGA_COMPLETA : float = 1.0
var carregando : bool = false

func _physics_process(delta: float) -> void:
	if not player or not player.is_alive:
		return

	# Segurando o botão de tiro
	if Input.is_action_pressed("shoot_p1"):
		carregando = true
		tempo_carregando += delta
		if player.som_carregando and not player.som_carregando.playing:
			player.som_carregando.play()

	# Soltando o botão de tiro
	if Input.is_action_just_released("shoot_p1") and carregando:
		carregando = false
		player.som_carregando.stop()
		
		# Define a direção da bala baseado no flip_h do sprite do Player
		var direcao = Vector2.LEFT if player.anim.flip_h else Vector2.RIGHT
		
		if tempo_carregando >= TEMPO_CARGA_COMPLETA:
			disparar_tiro_carregado(direcao)
		else:
			disparar_tiro_normal(direcao)
			
		tempo_carregando = 0.0

func disparar_tiro_normal(direction: Vector2) -> void:
	if bullet_scene == null: return
	
	var bullet = bullet_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.global_position = player.gun_point.global_position
	bullet.set_direction(direction)
	
	if player.som_tiro:
		player.som_tiro.play()

func disparar_tiro_carregado(direction: Vector2) -> void:
	if charged_bullet_scene == null: return
	
	var bullet = charged_bullet_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.global_position = player.gun_point.global_position
	bullet.set_direction(direction)
	
	if player.som_tiro_carregado:
		player.som_tiro_carregado.play()
