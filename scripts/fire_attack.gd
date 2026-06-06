extends Area2D

func _ready():
	print("SINAL CONECTADO")
	print("FOGO PRONTO")
func _on_body_entered(body):
	print(body.name)
	if body.has_method("receber_dano"):
		body.receber_dano(50)
