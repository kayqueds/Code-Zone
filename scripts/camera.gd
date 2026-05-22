extends Camera2D

@onready var player1 = $"../Player"
@onready var player2 = $"../Player2"

func _process(delta):

	if player1 and player2:

		global_position = (
			player1.global_position +
			player2.global_position
		) / 2
