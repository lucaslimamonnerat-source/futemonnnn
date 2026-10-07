extends Node

const SAVE_PATH_DEFAULT = "user://savegame.dat"
const SAVE_PATH_MILENA = "user://savegameMILENA.dat"
const SAVE_PATH_IRIS = "user://savegameIRIS.dat"

var game_data = {
	"current_scene": "",
	"player_position": Vector2.ZERO,
	# futuramente adicione mochila, time, etc.
}

# Função auxiliar para pegar o caminho correto com base no personagem
func get_save_path() -> String:
	match State.playerAtual:
		"Milena":
			return SAVE_PATH_MILENA
		"Iris":
			return SAVE_PATH_IRIS
		_:
			print("AVISO: Personagem atual ('%s') não reconhecido. Usando save padrão." % State.playerAtual)
			return SAVE_PATH_DEFAULT

# Útil para checar se a opção "Continuar" deve aparecer no menu do personagem
func has_save() -> bool:
	return FileAccess.file_exists(get_save_path())

func save_game():
	var save_path = get_save_path()
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		game_data["player_position"] = player.global_position
		# game_data["pokemon_team"] = player.get_team_data()
		# game_data["mochila"] = player.get_inventory_data()
	else:
		print("AVISO: Jogador não encontrado no grupo 'player'")
	
	game_data["current_scene"] = get_tree().current_scene.scene_file_path
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(game_data)
		file.close()
		print("Jogo de %s salvo com sucesso em: %s" % [State.playerAtual, save_path])
	else:
		print("Erro ao abrir arquivo para salvar em: ", save_path)

func load_game():
	var save_path = get_save_path()
	
	if not FileAccess.file_exists(save_path):
		print("Nenhum save encontrado para %s em: %s" % [State.playerAtual, save_path])
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		game_data = file.get_var()
		file.close()
		print("Save de %s carregado com sucesso!" % State.playerAtual)
	else:
		print("Erro ao ler arquivo de save em: ", save_path)
		return
	
	# Sinaliza que estamos carregando um save e define a posição a ser usada
	Game.is_loading_save = true
	Game.saved_player_position = game_data["player_position"]
	
	# Troca para a cena salva
	get_tree().change_scene_to_file(game_data["current_scene"])
