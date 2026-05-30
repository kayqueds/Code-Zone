extends AnimatableBody2D

@onready var target = $Marker2D

@export var time = 2.0

var start_position

func _ready():

	start_position = global_position

	print(target.global_position)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "global_position", target.global_position, time)

	tween.tween_property(self, "global_position", start_position, time)

	tween.set_loops()
