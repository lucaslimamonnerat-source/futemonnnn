extends Node2D

@export var escala_focado: Vector2 = Vector2(0.22, 0.22)
@export var escala_normal: Vector2 = Vector2(0.182, 0.182)
@export var tempo_animacao: float = 0.15

const selecionoupersonagem = "res://efeitosonoros/personagemselecionado.mp3"
const menumudandodefoco = "res://efeitosonoros/menumudandodefoco.wav"

var personagens: Array = []
var indice_selecionado: int = 0

var audio_foco: AudioStreamPlayer
var audio_selecao: AudioStreamPlayer

# Referência guardada da árvore para usar em trocas de cena
var tree_ref: SceneTree

func _ready() -> void:
	# Salva a referência da árvore logo no início
	MusicManager.tocar_musica("res://musics/menustartmusic.mp3")
	tree_ref = get_tree()
	
	# Configura o áudio de mudança de foco
	audio_foco = AudioStreamPlayer.new()
	audio_foco.stream = load(menumudandodefoco)
	add_child(audio_foco)
	
	# Configura o áudio de confirmação (abrir o mundo)
	audio_selecao = AudioStreamPlayer.new()
	audio_selecao.stream = load(selecionoupersonagem)
	add_child(audio_selecao)

	carregar_personagens(self)
	
	if personagens.size() > 0:
		atualizar_selecao(0)

func carregar_personagens(node: Node) -> void:
	for child in node.get_children():
		if child.name.begins_with("ShadowPlayer") and child is Area2D:
			personagens.append(child)
			child.scale = escala_normal
			
			if not child.input_event.is_connected(_on_personagem_input_event.bind(child)):
				child.input_event.connect(_on_personagem_input_event.bind(child))
				
		if child.get_child_count() > 0:
			carregar_personagens(child)

func _unhandled_input(event: InputEvent) -> void:
	if personagens.is_empty():
		return
		
	var direcao = Vector2.ZERO
	
	# Suporte a W, A, S, D e Setas direcionais
	if event.is_action_pressed("ui_up") or event.is_pressed() and (event is InputEventKey and event.keycode == KEY_W):
		direcao = Vector2.UP
	elif event.is_action_pressed("ui_down") or event.is_pressed() and (event is InputEventKey and event.keycode == KEY_S):
		direcao = Vector2.DOWN
	elif event.is_action_pressed("ui_left") or event.is_pressed() and (event is InputEventKey and event.keycode == KEY_A):
		direcao = Vector2.LEFT
	elif event.is_action_pressed("ui_right") or event.is_pressed() and (event is InputEventKey and event.keycode == KEY_D):
		direcao = Vector2.RIGHT
		
	if direcao != Vector2.ZERO:
		encontrar_proximo_por_direcao(direcao)
		
	if event.is_action_pressed("ui_accept"):
		ativar_personagem(personagens[indice_selecionado])

func encontrar_proximo_por_direcao(dir: Vector2) -> void:
	var atual = personagens[indice_selecionado]
	var melhor_indice = indice_selecionado
	var menor_distancia = INF
	
	for i in range(personagens.size()):
		if i == indice_selecionado:
			continue
			
		var outro = personagens[i]
		var vetor_diff = outro.global_position - atual.global_position
		
		var produto_escalar = vetor_diff.normalized().dot(dir)
		if produto_escalar > 0.3:
			var distancia = vetor_diff.length()
			if distancia < menor_distancia:
				menor_distancia = distancia
				melhor_indice = i
				
	if melhor_indice != indice_selecionado:
		atualizar_selecao(melhor_indice)

func atualizar_selecao(novo_indice: int) -> void:
	# Toca o som de foco APENAS se o índice realmente mudou (não toca no _ready)
	if novo_indice != indice_selecionado and audio_foco.stream:
		audio_foco.play()

	if personagens.size() > indice_selecionado:
		animar_personagem(personagens[indice_selecionado], escala_normal)
		
	indice_selecionado = novo_indice
	animar_personagem(personagens[indice_selecionado], escala_focado)

func animar_personagem(personagem: Area2D, escala_alvo: Vector2) -> void:
	# Anima APENAS a escala, mantendo as cores originais intactas (sem brilho)
	var tween = create_tween()
	tween.tween_property(personagem, "scale", escala_alvo, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Função que lida com o clique do mouse no personagem
func _on_personagem_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, personagem: Area2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var index = personagens.find(personagem)
		if index != -1:
			atualizar_selecao(index)
			ativar_personagem(personagem) # Manda direto pro mundo do personagem

func ativar_personagem(personagem: Area2D) -> void:
	# 1. Manda o MusicManager fazer o fade out de 2 segundos
	MusicManager.parar_musica_com_fadeout(2.0)
	
	# 2. Toca o som de confirmação
	if audio_selecao.stream:
		var temp_player = AudioStreamPlayer.new()
		temp_player.stream = audio_selecao.stream
		temp_player.volume_db = -4.5 # <--- AQUI! Abaixa o volume para ~60%
		tree_ref.root.add_child(temp_player)
		temp_player.play()
		temp_player.finished.connect(temp_player.queue_free)
		
	# 3. Muda de cena imediatamente
	if "ir" in personagem and personagem.ir != "":
		tree_ref.change_scene_to_file("res://scenes/" + personagem.ir)
