extends CharacterBody2D

const speed = 300.0
const jump_force = -400.0
const gravity = 900

func _ready() -> void:
	pass


func _physics_process(delta:float) -> void:
	move(delta)
	pass
	
func move(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimento
	var direction = Input.get_axis("Left", "Right")
	velocity.x = direction * speed

	# Pulo
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_force
	up_direction = Vector2.UP 
	
	move_and_slide()
	pass

	
