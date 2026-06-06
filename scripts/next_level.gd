extends Area2D

@export_file("*.tscn") var proxima_fase 

@onready var som_portal: AudioStreamPlayer2D = $PortalSound

var player1_entrou = false
var player2_entrou = false

func _on_body_entered(body):
	if body.name == "Player":
		preparar_player(body)
		player1_entrou = true
	elif body.name == "Player2":
		preparar_player(body)
		player2_entrou = true
	
	verificar_transicao()

func preparar_player(body):
	body.visible = false
	som_portal.play()
	body.set_physics_process(false)
	body.set_process(false)
	# Desativa o colisor para não triggar mais nada
	if body.has_node("CollisionShape2D"):
		body.get_node("CollisionShape2D").set_deferred("disabled", true)

func verificar_transicao():
	# Busca na árvore de cena atual
	var player1 = get_tree().current_scene.get_node_or_null("Player")
	var player2 = get_tree().current_scene.get_node_or_null("Player2")
	
	# Verifica se os jogadores existem antes de checar is_alive
	var p1_pronto = player1_entrou or (player1 and not player1.is_alive)
	var p2_pronto = player2_entrou or (player2 and not player2.is_alive)
	
	if p1_pronto and p2_pronto:
		trocar_fase()

func trocar_fase():
	# Impede que a troca seja chamada várias vezes
	set_deferred("monitoring", false)
	
	# Caso o arquivo da fase não tenha sido selecionado, avisa no console
	if proxima_fase == "":
		push_warning("Portal sem fase definida! Selecione o arquivo .tscn no Inspetor.")
		return
		
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(proxima_fase)
