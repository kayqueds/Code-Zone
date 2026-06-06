extends CanvasLayer

@onready var start_som = $StartSound
@onready var confirm_som = $ConfirmSound

var iniciando = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_som.play()

func _process(delta):

	if iniciando:
		return

	if Input.is_action_just_pressed("shoot_p1") \
	or Input.is_action_just_pressed("ataque_p2"):

		iniciando = true
		confirm_som.play()
		# Espera meio segundo
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scene/tropic.tscn")
