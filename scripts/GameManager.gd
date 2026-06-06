extends Node

var vidas = 3

func resetar_jogo():
	vidas = 3
	print("Jogo reiniciado! Vidas: ", vidas)

func perder_vida():
	vidas -= 1
	print("Vidas restantes: ", vidas)
	

func chamar_game_over():
	var gameover = get_tree().current_scene.find_child("GameOver", true, false)
	if gameover:
		gameover.ativar_menu()
