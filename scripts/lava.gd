extends TileMapLayer

func _physics_process(_delta):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		# A posição global precisa ser relativa à camada do mapa
		var local_pos = to_local(p.global_position)
		var map_pos = local_to_map(local_pos)
		
		# Pega a célula na camada
		var source_id = get_cell_source_id(map_pos)
		
		# Só checa se for um ID válido (diferente de -1)
		if source_id != -1:
			var data = get_cell_tile_data(map_pos)
			if data and data.get_custom_data("is_lethal"):
				if p.has_method("die"):
					p.die()
