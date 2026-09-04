extends CharacterBody2D

@onready var playerWalkingAudioStream = $playerandando
@onready var playerBatendoAudioStream = $playerbatendo
var VELOCIDADE = 200
var situationAtual = "idle"
var title_size = 16
var moving = false
var input_dir
@export var podeAndar: int = 1
var matos = []
var porta_proxima = null
var interagindo = false
var cena_destino = ""
var inventory = Inv.items
@onready var actionable_finder: Area2D = $Direction/ActionableFinger
@onready var marcado: Marker2D = $Direction

func _ready():
	randomize()
	print(">>> Jogador _ready. Game.vindo_da_casa=", Game.vindo_da_casa, " Game.ponto_retorno=", Game.ponto_retorno)

	# Apenas para carregamento de save
	if Game.is_loading_save:
		global_position = Game.saved_player_position
		Game.is_loading_save = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.is_empty():
			return
		if actionables[0].has_method("action"):
			actionables[0].action()
			if actionables[0].life == 0:
				Inv.picked(actionables[0].item_name)
				inventory = Inv.items
			return

func entrou_no_mato(mato):
	matos.append(mato)

func saiu_do_mato(mato):
	matos.erase(mato)

func tentar_encontro():
	if matos.is_empty():
		return
	for mato in matos:
		var roll = randi() % 100
		if roll < mato.chance_encontro:
			Game.player_position = global_position
			podeAndar = 0
			SceneTransition.change_scene("res://scenes/battle.tscn")
			return

func interagir_com_porta():
	interagindo = true
	podeAndar = 0
	print("Interagindo com porta: ", porta_proxima)

	if porta_proxima:
		porta_proxima.abrir_porta()
		porta_proxima.preparar_transicao()

	await get_tree().create_timer(0.3).timeout
	print("Trocando para cena: ", cena_destino)
	SceneTransition.change_scene(cena_destino)

func _process(delta: float) -> void:
	if Input.is_action_pressed("sair"):
		get_tree().change_scene_to_file("res://scenes/menu_start.tscn")

	if Input.is_action_just_pressed("ataque") and porta_proxima != null and not interagindo:
		interagir_com_porta()

	if podeAndar == 1:
		if moving:
			return
		input_dir = Vector2.ZERO
		if Input.is_action_pressed("direita"):
			input_dir = Vector2(1,0)
			situationAtual = "idleL"
			$animaco.flip_h = false
			$animaco.play("run")
			marcado.position.x = 5
			marcado.position.y = -5
			move()
		elif Input.is_action_pressed("esquerda"):
			input_dir = Vector2(-1,0)
			situationAtual = "idleL"
			$animaco.flip_h = true
			$animaco.play("run")
			marcado.position.x = -5
			marcado.position.y = -5
			move()
		elif Input.is_action_pressed("cima"):
			input_dir = Vector2(0,-1)
			situationAtual = "idleC"
			$animaco.flip_h = false
			$animaco.play("runC")
			marcado.position.x = 0
			marcado.position.y = -12
			move()
		elif Input.is_action_pressed("baixo"):
			input_dir = Vector2(0,1)
			situationAtual = "idle"
			$animaco.flip_h = false
			$animaco.play("runB")
			marcado.position.x = 0
			marcado.position.y = 0
			move()
		else:
			# Nenhuma tecla de direção → para o som de passos
			if playerWalkingAudioStream.playing:
				playerWalkingAudioStream.stop()
			$animaco.play(situationAtual)
	else:
		# Se não pode andar, também para o som
		if playerWalkingAudioStream.playing:
			playerWalkingAudioStream.stop()
		$animaco.play("idle")

	if Input.is_action_pressed("batata"):
		print(inventory)
		print(Inv.items)

func move():
	if input_dir != Vector2.ZERO:
		var colisao = move_and_collide(input_dir * title_size, true)
		if colisao:
			moving = false
			return
		moving = true
		# Toca o som de passos se ainda não estiver tocando
		if !playerWalkingAudioStream.playing:
			playerWalkingAudioStream.play()
		var destino = position + input_dir * title_size
		var tween = create_tween()
		tween.tween_property(self, "position", destino, 0.2)
		tween.tween_callback(move_false)
		tentar_encontro()

func move_false():
	moving = false
