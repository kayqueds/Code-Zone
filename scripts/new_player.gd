extends CharacterBody2D

var speed = 160.0
var jump_velocity = -300.0

var dir

var gravity = 980

var extra_jumps = 1

@onready var anim = $AnimatedSprite2D

var is_alive = true

@export var is_inverted = false

@export var input_left := "left_p1"
@export var input_right := "right_p1"
@export var input_jump := "jump_p1"

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	print(is_inverted)
	
	set_gravity()
	
	
	invert_move(delta)
	move(delta)
	
	
	if is_alive:
		animations()
	
	pass

func set_gravity():
	
	if Input.is_action_just_pressed("inverter_gravidade") and not is_inverted:
		is_inverted = true
	elif Input.is_action_just_pressed("inverter_gravidade") and is_inverted:
		is_inverted = false
	
	pass


func move(delta):
	
	if is_inverted:
		return
	
	if is_alive:
		dir = Input.get_axis(input_left , input_right)
	
	if dir:
		velocity.x = dir * speed
	elif dir == 0:
		velocity.x = 0
	
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed(input_jump) and extra_jumps > 0 and is_alive:
		velocity.y = jump_velocity
		extra_jumps -= 1
	
	if is_on_floor():
		extra_jumps = 1
	
	move_and_slide()
	
	pass

func invert_move(delta):
	
	if not is_inverted:
		return
	
	if is_alive:
		dir = Input.get_axis(input_left , input_right)
	
	if dir:
		velocity.x = dir * speed
	elif dir == 0:
		velocity.x = 0
	
	
	velocity.y += -gravity * delta
	
	if Input.is_action_just_pressed(input_jump) and extra_jumps > 0 and is_alive:
		velocity.y = -jump_velocity
		extra_jumps -= 1
	
	if is_on_ceiling():
		extra_jumps = 1
	
	move_and_slide()
	
	pass

func animations():
	
	if is_inverted:
		anim.flip_v = true
	else:
		anim.flip_v = false
	
	if velocity.x != 0 and is_on_floor():
		anim.play("walk")
	elif velocity.x == 0 and is_on_floor():
		anim.play("idle")
	
	if not is_on_floor() and extra_jumps >= 1:
		anim.play("jump")
	
	if dir > 0:
		anim.flip_h = false
	elif dir < 0:
		anim.flip_h = true
	
	pass

func die():
	
	if is_alive:
		
		is_alive = false
		anim.play("hit")
		
		$Area2D.queue_free()
		$CollisionShape2D.queue_free()
		velocity.y = jump_velocity - 100
		
		await get_tree().create_timer(1).timeout
		
		get_tree().reload_current_scene()
	
	pass
