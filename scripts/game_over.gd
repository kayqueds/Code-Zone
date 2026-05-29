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
	process_mode = Node.PROCESS_MODE_ALWAYS

	$ColorRect.visible = false
	$MenuSprite.visible = false
	# TESTE DIRETO
	

func ativar_menu():

	esta_ativo = true

	$ColorRect.visible = true
	$MenuSprite.visible = true

	get_tree().paused = true

	opcao_selecionada = 0

	menu_sprite.play("show_yes")

	if not gameover_music.playing:
		gameover_music.play()

func _process(delta):

	if not esta_ativo:
		return

	# YES
	if Input.is_action_just_pressed("left_p1"):

		print("LEFT")

		opcao_selecionada = 0

		menu_sprite.play("show_yes")

		move_sound.play()

	# NO
	if Input.is_action_just_pressed("right_p1"):

		print("RIGHT")

		opcao_selecionada = 1

		menu_sprite.play("show_no")

		move_sound.play()

	# CONFIRMAR
	# CONFIRMAR
	if Input.is_action_just_pressed("shoot_p1") or Input.is_action_just_pressed("ataque_p2"):
		print("CONFIRMAR")
		
		# 1. Toca o som
		confirm_sound.play()
		
		# 2. Desativa a interação para o jogador não apertar de novo
		esta_ativo = false 
		
		# 3. Espera o som terminar (o sinal 'finished' é emitido automaticamente)
		await confirm_sound.finished
		
		# 4. Agora sim, executa a lógica
		if opcao_selecionada == 0:
			gameover_music.stop()
			get_tree().paused = false
			get_tree().reload_current_scene()
		else:
			gameover_music.stop()
			get_tree().quit()
