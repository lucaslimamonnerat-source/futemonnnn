extends Node2D

func _ready():
	print(">>> inicio.tscn _ready. has_pending_position=", Game.has_pending_position)
	if Game.is_loading_save:
		$player.global_position = Game.saved_player_position
		Game.is_loading_save = false
		Game.saved_player_position = Vector2.ZERO
	elif Game.has_pending_position:
		$player.global_position = Game.pending_player_position
		print("   Posicionando player na posição pendente: ", Game.pending_player_position)
		Game.has_pending_position = false
		Game.pending_player_position = Vector2.ZERO
	else:
		$player.global_position = Game.player_spawn_position
		print("   Spawn normal. Posição do player: ", $player.global_position)
