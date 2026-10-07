#menudesavedospersonagens
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

	# Conecta os botões via código aos seus respectivos métodos
	btn_milena.pressed.connect(_on_button_milena_pressed)
	btn_iris.pressed.connect(_on_button_iris_pressed)
	
	# Verifica se os saves existem para desabilitar o botão se não houver save
	State.playerAtual = "Milena"
	btn_milena.disabled = not SistemadeSave.has_save()
	
	State.playerAtual = "Iris"
	btn_iris.disabled = not SistemadeSave.has_save()

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
