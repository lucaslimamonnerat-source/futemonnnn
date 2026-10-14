extends Node

var audio_player: AudioStreamPlayer
var musica_atual: String = ""

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func tocar_musica(caminho: String) -> void:
	if musica_atual == caminho and audio_player.playing:
		return
		
	musica_atual = caminho
	var som = load(caminho)
	
	if som:
		audio_player.stream = som
		audio_player.volume_db = 0.0 # Garante que o volume comece no máximo
		audio_player.play()
	else:
		print("ERRO: Música não encontrada em: ", caminho)

# NOVA FUNÇÃO: Faz a música sumir suavemente (fade out)
func parar_musica_com_fadeout(duracao: float = 2.0) -> void:
	if not audio_player.playing:
		return
		
	# Cria uma animação (Tween) que abaixa o volume de 0 (máximo) até -80 (silêncio)
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80.0, duracao)
	
	# Quando a animação terminar, para o som de vez e reseta o volume
	tween.tween_callback(_finalizar_musica)

func _finalizar_musica() -> void:
	audio_player.stop()
	audio_player.volume_db = 0.0 # Reseta para a próxima vez que tocar
	musica_atual = ""
