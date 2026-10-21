extends Control

@export var escala_focado: Vector2 = Vector2(1.05, 1.05)
@export var cor_focado: Color = Color(0.502, 0.502, 0.502, 1.0)
@export var deslocamento_esquerda: float = 7.0
@export var tempo_animacao: float = 0.15

const SOM_FOCO = "res://efeitosonoros/menumudandodefoco.wav" # Caminho do som

var cores_originais: Dictionary = {}
var posricoes_originais: Dictionary = {}
var botoes: Array[Button] = [] # Lista para guardar os botões e facilitar a navegação

var audio_player: AudioStreamPlayer
var pode_tocar_som: bool = false # Evita tocar o som assim que o menu abre

func _ready() -> void:
	# Configura o áudio de mudança de foco
	audio_player = AudioStreamPlayer.new()
	MusicManager.tocar_musica("res://musics/menustartmusic.mp3")
	audio_player.stream = load(SOM_FOCO)
	add_child(audio_player)

	configurar_botoes(self)
	conectar_sinais_foco(self)

	# Garante que o primeiro botão recebe o foco inicial
	$Button.grab_focus()
	pode_tocar_som = true # Libera o som depois que o menu já carregou

func configurar_botoes(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			botoes.append(child) # Adiciona o botão na nossa lista
			
			child.pivot_offset = Vector2(0, child.size.y / 2.0)
			posricoes_originais[child] = child.position
			
			# Garante que o botão consegue receber cliques do rato
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Remove a caixinha/borda de foco definindo um StyleBox vazio
			child.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			
			var estilo_normal = child.get_theme_stylebox("normal")
			if estilo_normal is StyleBoxFlat:
				var novo_estilo = estilo_normal.duplicate()
				cores_originais[child] = novo_estilo.bg_color
				child.add_theme_stylebox_override("normal", novo_estilo)
		if child.get_child_count() > 0:
			configurar_botoes(child)

func conectar_sinais_foco(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.focus_entered.connect(_on_botao_focus_entered.bind(child))
			child.focus_exited.connect(_on_botao_focus_exited.bind(child))
		if child.get_child_count() > 0:
			conectar_sinais_foco(child)

# NOVA FUNÇÃO: Lê o WASD para navegar no menu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var foco_atual = get_viewport().gui_get_focus_owner()
		
		if foco_atual is Button and foco_atual in botoes:
			var index = botoes.find(foco_atual)
			
			if event.keycode == KEY_W:
				var prox_index = (index - 1 + botoes.size()) % botoes.size()
				botoes[prox_index].grab_focus()
				get_viewport().set_input_as_handled() # Impede que o Godot tente fazer outra coisa
				
			elif event.keycode == KEY_S:
				var prox_index = (index + 1) % botoes.size()
				botoes[prox_index].grab_focus()
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	pass

func _on_botao_focus_entered(botao: Button) -> void:
	# Toca o som de foco
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

func _on_botao_focus_exited(botao: Button) -> void:
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(botao, "scale", Vector2.ONE, tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if botao in posricoes_originais:
		tween.tween_property(botao, "position", posricoes_originais[botao], tempo_animacao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var estilo = botao.get_theme_stylebox("normal") as StyleBoxFlat
	if estilo and botao in cores_originais:
		create_tween().tween_property(estilo, "bg_color", cores_originais[botao], tempo_animacao)

# Funções de clique e ações:
func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/savePersonagens.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/home.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
