extends Camera2D

@onready var player1 = $"../Player"
@onready var player2 = $"../Player2"

func _process(delta):
	var alvos = []
	
	# Adiciona à lista APENAS se estiver vivo
	if player1.is_alive:
		alvos.append(player1.global_position)
	if player2.is_alive:
		alvos.append(player2.global_position)
		
	# Se houver alvos vivos, calcula a posição
	if alvos.size() > 0:
		var target_pos = Vector2.ZERO
		for pos in alvos:
			target_pos += pos
		target_pos /= alvos.size()
		
		# Move suavemente para o alvo
		global_position = lerp(global_position, target_pos, 0.1)
	
	# Se alvos.size() for 0 (ambos mortos), a câmera simplesmente 
	# não faz nada, mantendo-se na última posição conhecida.
