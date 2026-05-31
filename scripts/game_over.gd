extends CanvasLayer

var opcao_selecionada = 0
var esta_ativo = false

@onready var move_sound = $MoveSound
@onready var confirm_sound = $ConfirmSound
@onready var menu_sprite = $MenuSprite
@onready var gameover_music = $GameOverMusic

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	menu_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	move_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	gameover_music.process_mode = Node.PROCESS_MODE_ALWAYS

	# Começa escondido
	visible = true
	$ColorRect.visible = false
	$MenuSprite.visible = false

func ativar_menu():

	print("GAME OVER ATIVADO")

	esta_ativo = true

	# Mostra elementos do menu
	$ColorRect.visible = true
	$MenuSprite.visible = true

	get_tree().paused = true

	opcao_selecionada = 0
	menu_sprite.play("show_yes")

	if not gameover_music.playing:
		gameover_music.play()

func _process(_delta):

	if not esta_ativo:
		return

	# YES
	if Input.is_action_just_pressed("left_p1"):

		opcao_selecionada = 0
		menu_sprite.play("show_yes")
		move_sound.play()

	# NO
	elif Input.is_action_just_pressed("right_p1"):

		opcao_selecionada = 1
		menu_sprite.play("show_no")
		move_sound.play()

	# CONFIRMAR
	if Input.is_action_just_pressed("shoot_p1") \
	or Input.is_action_just_pressed("ataque_p2"):

		esta_ativo = false

		confirm_sound.play()
		await confirm_sound.finished

		gameover_music.stop()
		get_tree().paused = false

		if opcao_selecionada == 0:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene_to_file("res://scene/start.tscn")
