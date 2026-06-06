extends Area2D

func _ready():
	# 1. Garante que este nó não é sólido (não serve como chão/parede)
	# Definimos a layer como 0 (vazia)
	collision_layer = 0
	
	# 2. Garante que ele 'escuta' apenas a camada 2 (onde o player está)
	# O set_collision_mask_value(2, true) ativa a máscara da camada 2
	set_collision_mask_value(1, false) # Desliga a camada 1 se estiver ativa
	set_collision_mask_value(2, true)  # Liga a camada 2

func _on_body_entered(body):
	# Verifica se o objeto que entrou está no grupo "player"
	if body.is_in_group("player"):
		# Chama a função de dano do seu player
		if body.has_method("receber_dano"):
			body.receber_dano(100)
