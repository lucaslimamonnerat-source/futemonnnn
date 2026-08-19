extends Node

const SAVE_PATH = "user://savegame.dat"

var game_data = {
	"current_scene": "",
	"player_position": Vector2.ZERO,
	# futuramente adicione mochila, time, etc.
}

func save_game():
	# Procura pelo grupo "player" (minúsculo, igual você usa nos outros scripts)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		game_data["player_position"] = player.global_position
		# Se tiver as funções, descomente depois:
		# game_data["pokemon_team"] = player.get_team_data()
		# game_data["mochila"] = player.get_inventory_data()
	else:
		print("AVISO: Jogador não encontrado no grupo 'player'")
	
	game_data["current_scene"] = get_tree().current_scene.scene_file_path
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(game_data)
		file.close()
		print("Jogo salvo com sucesso!")
	else:
		print("Erro ao abrir arquivo para salvar.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nenhum save encontrado.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		game_data = file.get_var()
		file.close()
	
	# Sinaliza que estamos carregando um save e define a posição a ser usada
	Game.is_loading_save = true
	Game.saved_player_position = game_data["player_position"]
	
	# Troca para a cena salva
	get_tree().change_scene_to_file(game_data["current_scene"])
