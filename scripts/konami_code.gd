extends Node

# A sequência exata de inputs usando as suas strings do Input Map
const KONAMI_SEQUENCE = [
	"jump_p1", "jump_p1", 
	"down_p1", "down_p1", 
	"left_p1", "right_p1", 
	"left_p1", "right_p1", 
	"shoot_p1", "ui-accept"
]

var current_index = 0

func _input(event):
	# Garante que só roda no momento exato do clique físico do botão/tecla
	if event.is_pressed() and not event.is_echo():
		var expected_input = KONAMI_SEQUENCE[current_index]
		
		# Procura se o botão que você apertou está mapeado para a ação esperada
		if event.is_action(expected_input):
			current_index += 1
			print("Konami Code progresso: ", current_index, "/", KONAMI_SEQUENCE.size())
			
			# Se completou toda a sequência!
			if current_index == KONAMI_SEQUENCE.size():
				ativar_jailson_mendes()
				current_index = 0 
		else:
			# Se você apertar algo que pertença às ações do Konami, mas fora de hora, reseta.
			# Checa se o que você apertou não é o início de tudo de novo (Pulo)
			if event.is_action(KONAMI_SEQUENCE[0]):
				current_index = 1
			else:
				# Ignora botões do sistema que não têm nada a ver com o combo (ex: mouse, esc)
				# mas reseta se for um botão de movimento errado
				for action in KONAMI_SEQUENCE:
					if event.is_action(action):
						current_index = 0
						break

func ativar_jailson_mendes():
	print("AI QUE DELÍCIA, CARA!")
	get_tree().change_scene_to_file("res://scene/tela_jailson.tscn")
