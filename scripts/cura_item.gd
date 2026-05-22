extends Area2D

# Menu de seleção para definir o alvo do item no Inspector
enum DonoDoItem { PYTHON_P1, JAVA_P2 }
@export var item_para: DonoDoItem = DonoDoItem.PYTHON_P1

@export var quantidade_cura: int = 20
@export var sprite_textura: Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite_textura:
		sprite_2d.texture = sprite_textura
		
	# Garante que as propriedades de colisão estão certas
	monitoring = true
	monitorable = false
	
	# Reseta as máscaras e foca apenas na Layer 2 (onde estão os players)
	for i in range(1, 32):
		set_collision_mask_value(i, false)
	set_collision_mask_value(2, true) # Layer 2: player

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem colidiu tem a função de curar
	if body.has_method("curar"):
		
		# Se o item for para o Python (P1), mas quem entrou foi o P2 (ou vice-versa), ignora!
		if item_para == DonoDoItem.PYTHON_P1 and "p2" in body.input_left:
			return
		if item_para == DonoDoItem.JAVA_P2 and not ("p2" in body.input_left):
			return
			
		# Se passou do filtro, tenta curar o player certo
		var curou = body.curar(quantidade_cura)
		if curou:
			queue_free() # Remove o item do mapa
