extends Camera2D

@onready var player1 = $"../Player"
@onready var player2 = $"../Player2"

func _process(delta):

	# Os dois vivos
	if player1.is_alive and player2.is_alive:

		global_position = (
			player1.global_position +
			player2.global_position
		) / 2

	# Só Player1 vivo
	elif player1.is_alive:

		global_position = player1.global_position

	# Só Player2 vivo
	elif player2.is_alive:

		global_position = player2.global_position
