extends Area2D

@export var cena_destino: String = ""   # será sobrescrito automaticamente
var marker_saida: Marker2D = null
var player_perto = false
var sou_porta_de_fora = false

func _ready():
	var cena_atual = get_tree().current_scene.scene_file_path
	sou_porta_de_fora = (cena_atual == "res://scenes/inicio.tscn")
	print(">>> Porta _ready. Cena atual: ", cena_atual, " -> sou_porta_de_fora=", sou_porta_de_fora)

	if sou_porta_de_fora and has_node("frentedaporta"):
		marker_saida = $frentedaporta
		print("   Marker encontrado! Posição global: ", marker_saida.global_position)
	else:
		print("   Sem marker (ou não é porta de fora).")

	# Define destino
	if sou_porta_de_fora:
		cena_destino = "res://scenes/Dentro.tscn"
	else:
		cena_destino = "res://scenes/inicio.tscn"
	print("   cena_destino = ", cena_destino)

	if has_node("CasaWip"):
		$CasaWip.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("cena_destino definido para: ", cena_destino)

func abrir_porta():
	if has_node("CasaWip"):
		$CasaWip.visible = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_perto = true
		body.porta_proxima = self
		body.cena_destino = cena_destino

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_perto = false
		body.porta_proxima = null

func preparar_transicao():
	var cena_atual = get_tree().current_scene.scene_file_path
	print(">>> Porta.preparar_transicao. sou_porta_de_fora=", sou_porta_de_fora)
	if sou_porta_de_fora:
		# Estamos ENTRANDO na casa: guarda ponto de retorno
		Game.ponto_retorno = marker_saida.global_position if marker_saida else global_position
		Game.cena_anterior = cena_atual
		Game.vindo_da_casa = false
		print("   Salvando ponto_retorno: ", Game.ponto_retorno)
	else:
		# Estamos SAINDO da casa: define posição pendente para o jogador
		Game.pending_player_position = Game.ponto_retorno
		Game.has_pending_position = true
		Game.vindo_da_casa = true  # ainda pode ser útil para outras lógicas
		print("   Definindo pending_position = ", Game.pending_player_position)
