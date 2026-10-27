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
	if event is InputEventKey and event.pressed and not event.echo:
		# Verifica se a tecla pressionada é ESC ou X para voltar
		if event.physical_keycode == KEY_ESCAPE or event.physical_keycode == KEY_X:
			get_tree().change_scene_to_file("res://scenes/menu_start.tscn")
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
			return

		# Suporte a WASD e Setinhas para navegar entre os botões
		var focused = get_viewport().gui_get_focus_owner()
		if not focused is Button:
			return
		
		if event.physical_keycode == KEY_W or event.physical_keycode == KEY_UP:
			var next_node = focused.find_valid_focus_neighbor(SIDE_TOP)
			if next_node:
				next_node.grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()
		elif event.physical_keycode == KEY_S or event.physical_keycode == KEY_DOWN:
			var next_node = focused.find_valid_focus_neighbor(SIDE_BOTTOM)
			if next_node:
				next_node.grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()
		elif event.physical_keycode == KEY_A or event.physical_keycode == KEY_LEFT:
			var next_node = focused.find_valid_focus_neighbor(SIDE_LEFT)
			if next_node:
				next_node.grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()
		elif event.physical_keycode == KEY_D or event.physical_keycode == KEY_RIGHT:
			var next_node = focused.find_valid_focus_neighbor(SIDE_RIGHT)
			if next_node:
				next_node.grab_focus()
				var vp = get_viewport()
				if vp:
					vp.set_input_as_handled()

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
