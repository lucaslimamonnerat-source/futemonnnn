extends Control

@export var escala_focado: Vector2 = Vector2(1.05, 1.05)
@export var cor_focado: Color = Color(0.502, 0.502, 0.502, 1.0)
@export var deslocamento_esquerda: float = 7.0
@export var tempo_animacao: float = 0.15

const SOM_FOCO = "res://efeitosonoros/menumudandodefoco.wav"

var cores_originais: Dictionary = {}
var posricoes_originais: Dictionary = {}
var botoes: Array[Control] = [] # Mudado para Control para aceitar o OptionButton
var audio_player: AudioStreamPlayer
var pode_tocar_som: bool = false

@onready var botao_resolucao: OptionButton = $BotaoResolucao

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = load(SOM_FOCO)
	add_child(audio_player)

	# Configura as opções de resolução
	botao_resolucao.add_item("1280 x 720 (HD)")
	botao_resolucao.add_item("1920 x 1080 (Full HD)")
	botao_resolucao.add_item("1366 x 768")
	botao_resolucao.alignment = HORIZONTAL_ALIGNMENT_CENTER # Centraliza o texto
	botao_resolucao.item_selected.connect(_on_resolucao_selecionada)

	# Organiza os botões manualmente na ordem: BotaoResolucao -> Button3 -> Button4 -> Button2
	var b1 = find_child("BotaoResolucao", true, false) as Control
	var b2 = find_child("Button2", true, false) as Control
	var b3 = find_child("Button3", true, false) as Control
	var b4 = find_child("Button4", true, false) as Control

	if b1: botoes.append(b1)
	if b3: botoes.append(b3)
	if b4: botoes.append(b4)
	if b2: botoes.append(b2)

	for b in botoes:
		b.pivot_offset = Vector2(0, b.size.y / 2.0)
		posricoes_originais[b] = b.position
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		var estilo_normal = b.get_theme_stylebox("normal")
		if estilo_normal is StyleBoxFlat:
			var novo_estilo = estilo_normal.duplicate()
			cores_originais[b] = novo_estilo.bg_color
			b.add_theme_stylebox_override("normal", novo_estilo)
			
		b.focus_entered.connect(_on_botao_focus_entered.bind(b))
		b.focus_exited.connect(_on_botao_focus_exited.bind(b))

	if botoes.size() > 0:
		botoes[0].grab_focus()
		
	pode_tocar_som = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_X or event.physical_keycode == KEY_BACKSPACE:
			_on_voltar_pressed()
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
			return

		var foco_atual = get_viewport().gui_get_focus_owner()
		
		if foco_atual and foco_atual in botoes:
			var index = botoes.find(foco_atual)
			
			if event.physical_keycode == KEY_W:
				var prox_index = (index - 1 + botoes.size()) % botoes.size()
				botoes[prox_index].grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()
				
			elif event.physical_keycode == KEY_S:
				var prox_index = (index + 1) % botoes.size()
				botoes[prox_index].grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()

func _on_resolucao_selecionada(index: int) -> void:
	var nova_resolucao = Vector2i.ZERO
	match index:
		0: nova_resolucao = Vector2i(1280, 720)
		1: nova_resolucao = Vector2i(1920, 1080)
		2: nova_resolucao = Vector2i(1366, 768)
			
	if nova_resolucao != Vector2i.ZERO:
		# Altera o tamanho da janela atual do jogo diretamente
		get_window().size = nova_resolucao
		
		# Centraliza a janela na tela do computador
		var current_screen = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(current_screen)
		var screen_position = DisplayServer.screen_get_position(current_screen)
		
		get_window().position = screen_position + (screen_size - nova_resolucao) / 2
		
func _on_botao_focus_entered(botao: Control) -> void:
	if pode_tocar_som and audio_player and audio_player.stream:
		audio_player.play()

	var tween = create_tween().set_parallel(true)
	tween.tween_property(botao, "scale", escala_focado, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if botao in posricoes_originais:
		var nova_pos = posricoes_originais[botao] - Vector2(deslocamento_esquerda, 0)
		tween.tween_property(botao, "position", nova_pos, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var estilo = botao.get_theme_stylebox("normal") as StyleBoxFlat
	if estilo:
		create_tween().tween_property(estilo, "bg_color", cor_focado, tempo_animacao)

func _on_botao_focus_exited(botao: Control) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(botao, "scale", Vector2.ONE, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if botao in posricoes_originais:
		tween.tween_property(botao, "position", posricoes_originais[botao], tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var estilo = botao.get_theme_stylebox("normal") as StyleBoxFlat
	if estilo and botao in cores_originais:
		create_tween().tween_property(estilo, "bg_color", cores_originais[botao], tempo_animacao)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_start.tscn")
