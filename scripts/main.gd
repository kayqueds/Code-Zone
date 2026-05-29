extends Node2D

var vidas = 3

@onready var player1 = $Player
@onready var player2 = $Player2
@onready var gameover = $GameOver

func verificar_players():

	if not player1.is_alive and not player2.is_alive:

		vidas -= 1

		print("VIDAS RESTANTES: ", vidas)

		if vidas > 0:

			respawn_players()

		else:

			gameover.ativar_menu()

func respawn_players():

	player1.respawn()
	player2.respawn()
