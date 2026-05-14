extends Camera2D

var target: Node2D

func _ready() -> void:
	await get_tree().process_frame
	get_target()
	print("PLAYER OK")

func _process(_delta: float) -> void:

	if target:
		position = target.position

func get_target():

	var nodes = get_tree().get_nodes_in_group("Player")

	if nodes.size() == 0:
		push_error("Player not found")
		return

	target = nodes[0]
