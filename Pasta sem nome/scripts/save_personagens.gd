extends Control

var btn_milena: Button
var btn_iris: Button

func _ready() -> void:
	# Busca os botões pelo nome dentro da cena (independente da estrutura do Panel)
	btn_milena = find_child("Button", true, false) as Button
	btn_iris = find_child("Button4", true, false) as Button

	# Validação para evitar crash se o nó não for encontrado
	if not btn_milena or not btn_iris:
		print("ERRO: Botões não encontrados na cena!")
		return

	# Remove a borda/caixinha de foco padrão de ambos os botões
	btn_milena.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_iris.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	# Conecta os botões via código aos seus respectivos métodos
	btn_milena.pressed.connect(_on_button_milena_pressed)
	btn_iris.pressed.connect(_on_button_iris_pressed)
	
	# Verifica se os saves existem para desabilitar o botão se não houver save
	State.playerAtual = "Milena"
	btn_milena.disabled = not SistemadeSave.has_save()
	
	State.playerAtual = "Iris"
	btn_iris.disabled = not SistemadeSave.has_save()
	
	# Define o foco inicial em um botão válido (se o milena estiver desabilitado, joga para o iris se possível)
	if not btn_milena.disabled:
		btn_milena.grab_focus()
	elif not btn_iris.disabled:
		btn_iris.grab_focus()
	else:
		btn_milena.grab_focus() # Fallback

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Verifica se a tecla pressionada é o ESC
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/menu_start.tscn")
			return

		# Suporte a WASD e Setinhas para navegar entre os botões
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
