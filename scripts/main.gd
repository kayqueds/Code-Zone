extends Node2D

@onready var player1 = $Player
@onready var player2 = $Player2
@onready var gameover = $GameOver

# Variável de controle para evitar que o código rode múltiplas vezes
var esta_processando_morte = false

func _ready():
	# Inicialização básica
	esta_processando_morte = false

# Esta função deve ser chamada dentro do die() de CADA player
func verificar_players():
	# Se já estamos processando um respawn ou game over, ignoramos novas chamadas
	if esta_processando_morte:
		return

	# Verifica se AMBOS morreram
	if not player1.is_alive and not player2.is_alive:
		esta_processando_morte = true
		
		# Desconta a vida no GameManager
		GameManager.perder_vida()
		
		# Espera um pouco antes de tomar a decisão (tempo de animação)
		await get_tree().create_timer(0.5).timeout 
		
		# Verifica se o jogo acabou ou se deve renascer
		# Nota: Ajuste a lógica de vidas conforme o que o GameManager retorna
		if GameManager.vidas > 0:
			respawn_players()
			# Libera para novas mortes futuras
			esta_processando_morte = false
		else:
			# Chama o menu de Game Over
			gameover.ativar_menu()
			# Não resetamos o esta_processando_morte aqui para travar o jogo no menu

func respawn_players():
	player1.respawn()
	player2.respawn()
