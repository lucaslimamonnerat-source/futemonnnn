extends Control

@export var escala_focado: Vector2 = Vector2(1.05, 1.05)
@export var cor_focado: Color = Color(0.502, 0.502, 0.502, 1.0)
@export var deslocamento_esquerda: float = 7.0
@export var tempo_animacao: float = 0.15

var cores_originais: Dictionary = {}
var posricoes_originais: Dictionary = {}

var btn_milena: Button
var btn_iris: Button

func _ready() -> void:
	# Busca os botões pelo nome dentro da cena (suporta Button e Button4)
	btn_milena = find_child("Button", true, false) as Button
	btn_iris = find_child("Button4", true, false) as Button

	if not btn_milena or not btn_iris:
		print("ERRO: Botões não encontrados na cena!")
		return

	# Configura a animação, pivô e estilo de cada botão
	configurar_botoes(self)
	conectar_sinais_foco(self)
	
	# Conecta os sinais de clique (pressed) aos métodos correspondentes
	btn_milena.pressed.connect(_on_button_milena_pressed)
	btn_iris.pressed.connect(_on_button_iris_pressed)
	
	# Verifica se os saves existem para desabilitar o botão se não houver save
	State.playerAtual = "Milena"
	btn_milena.disabled = not SistemadeSave.has_save()
	
	State.playerAtual = "Iris"
	btn_iris.disabled = not SistemadeSave.has_save()
	
	# Garante que o primeiro botão disponível recebe o foco inicial
	if not btn_milena.disabled:
		btn_milena.grab_focus()
	elif not btn_iris.disabled:
		btn_iris.grab_focus()
	else:
		btn_milena.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Pressionar ESC volta para a última cena gravada no State (ou menu_start se vazia)
		if event.keycode == KEY_ESCAPE:
			var cena_destino = State.ultima_cena if State.ultima_cena != "" else "res://scenes/menu_start.tscn"
			get_tree().change_scene_to_file(cena_destino)
			return
		
		# Navegação via WASD e Setinhas
		var focused = get_viewport().gui_get_focus_owner()
		if not focused is Button:
			return
		
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			var next_node = focused.find_valid_focus_neighbor(SIDE_TOP)
			if next_node:
				next_node.grab_focus()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_S or event.keycode == KEY_DOWN:
			var next_node = focused.find_valid_focus_neighbor(SIDE_BOTTOM)
			if next_node:
				next_node.grab_focus()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_A or event.keycode == KEY_LEFT:
			var next_node = focused.find_valid_focus_neighbor(SIDE_LEFT)
			if next_node:
				next_node.grab_focus()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			var next_node = focused.find_valid_focus_neighbor(SIDE_RIGHT)
			if next_node:
				next_node.grab_focus()
				get_viewport().set_input_as_handled()

func configurar_botoes(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.pivot_offset = Vector2(0, child.size.y / 2.0)
			posricoes_originais[child] = child.position
			
			# Garante que o botão consegue receber cliques do rato
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Remove a caixinha/borda de foco padrão da Godot
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

func _on_botao_focus_entered(botao: Button) -> void:
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

func _on_button_milena_pressed() -> void:
	State.playerAtual = "Milena"
	if SistemadeSave.has_save():
		SistemadeSave.load_game()
	else:
		print("Nenhum save encontrado para Milena.")

func _on_button_iris_pressed() -> void:
	State.playerAtual = "Iris"
	if SistemadeSave.has_save():
		SistemadeSave.load_game()
	else:
		print("Nenhum save encontrado para Iris.")
