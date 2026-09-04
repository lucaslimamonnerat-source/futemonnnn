extends Node
var player_spawn_position: Vector2 = Vector2.ZERO
var vindo_da_casa = false
var is_loading_save = false
var saved_player_position = Vector2.ZERO

# NOVO
var ponto_retorno: Vector2 = Vector2.ZERO   # posição pra onde o player volta ao SAIR
var cena_anterior: String = ""              # cena externa, pra voltar pra ela

# Sistema de posição pendente (mais confiável)
var pending_player_position: Vector2 = Vector2.ZERO
var has_pending_position: bool = false
