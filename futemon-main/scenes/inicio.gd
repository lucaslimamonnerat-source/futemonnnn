extends Node2D

func _ready():
	if Game.is_loading_save:
		# Usa a posição salva e depois reseta a flag
		$player.global_position = Game.saved_player_position
		Game.is_loading_save = false
		Game.saved_player_position = Vector2.ZERO
	else:
		# Jogo novo: posição padrão
		$player.global_position = Game.player_spawn_position
