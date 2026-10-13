extends Node2D

@export var escala_focado: Vector2 = Vector2(0.22, 0.22)
@export var escala_normal: Vector2 = Vector2(0.182, 0.182)
@export var tempo_animacao: float = 0.15

var personagens: Array = []
var indice_selecionado: int = 0

func _ready() -> void:
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
	if personagens.size() > indice_selecionado:
		animar_personagem(personagens[indice_selecionado], escala_normal)
		
	indice_selecionado = novo_indice
	animar_personagem(personagens[indice_selecionado], escala_focado)

func animar_personagem(personagem: Area2D, escala_alvo: Vector2) -> void:
	# Anima APENAS a escala, mantendo as cores originais intactas (sem brilho)
	var tween = create_tween()
	tween.tween_property(personagem, "scale", escala_alvo, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_personagem_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, personagem: Area2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var index = personagens.find(personagem)
		if index != -1:
			atualizar_selecao(index)
			ativar_personagem(personagem)

func ativar_personagem(personagem: Area2D) -> void:
	if "ir" in personagem and personagem.ir != "":
		get_tree().change_scene_to_file("res://scenes/" + personagem.ir)
