extends CanvasLayer

#codigomenu
@onready var select_arrow = $Control/NinePatchRect/TextureRect
@onready var menu = $Control
@onready var audio_menu = $AudioMenu
@onready var aviso_save = $AvisoSave
@onready var nome = $Control/NinePatchRect/VBoxContainer/RichTextLabel3

enum ScreenLoaded { NOTHING, JUST_MENU, PARTY_SCREEN, AUDIO_MENU }
var screen_loaded = ScreenLoaded.NOTHING
var selected_option: int = 0
var inv_selected: int = 0
var itens: Array = []
var about: Node = null

func _ready() -> void:
	menu.visible = false
	audio_menu.visible = false
	aviso_save.visible = false
	
	about = get_tree().get_first_node_in_group("about")
	if about:
		about.visible = false

	select_arrow.position.y = 5
	audio_menu.closed.connect(_on_audio_menu_closed)

	var item_vel = ItemVelocidade.new()
	var item_cor = ItemCor.new()
	itens = [item_vel, item_cor, null, null,
			 null, null, null, null,
			 null, null, null, null,
			 null, null, null, null]

func _show_quit_confirmation():
	var dialogue_resource = load("res://dialogue/quit_confirmation.dialogue")
	if dialogue_resource:
		DialogueManager.show_dialogue_balloon(dialogue_resource)
		menu.visible = false
	else:
		print("Erro: diálogo não encontrado")

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				var player = get_tree().get_first_node_in_group("player")
				if player and !player.moving:
					player.set_process(false)
					menu.visible = true
					State.menu_aberto = true
					screen_loaded = ScreenLoaded.JUST_MENU
					selected_option = 0
					select_arrow.position.y = 5

		ScreenLoaded.JUST_MENU:
			nome.text = State.playerAtual
			if event.is_action_pressed("menu") or event.is_action_pressed("voltar"):
				_close_menu()
			elif event.is_action_pressed("ataque"):
				print("Opção confirmada: ", selected_option)
				match selected_option:
					0: 
						_close_menu()
					1:
						var inventory = get_tree().get_first_node_in_group("Inventory")
						if inventory:
							inventory.get_node("Control").visible = true
							inv_selected = 0
							var arrow_inv = inventory.get_node("Control/NinePatchRect/TextureRect")
							arrow_inv.position = Vector2(9, 7)
							select_arrow.visible = false
							screen_loaded = ScreenLoaded.PARTY_SCREEN
					2:
						if not about:
							about = get_tree().get_first_node_in_group("about")

						if about:
							about.visible = !about.visible
							
							if about.visible:
								about.get_node("Panel/HBoxContainer/VBoxContainer/Label").text = "Nome: " + State.playerAtual
								if State.playerAtual == "Milena":
									about.get_node("Panel/HBoxContainer/VBoxContainer/TextureRect").texture = load("res://sprites/Milena2.0/MilenaDeFrente.png")
									about.get_node("Panel/HBoxContainer/VBoxContainer/Label3").text = "Milena é uma jovem exploradora e jornalista em busca de conhecer os limites do mundo"
								elif State.playerAtual == "Iris":
									about.get_node("Panel/HBoxContainer/VBoxContainer/TextureRect").texture = load("res://sprites/Iris/Iris.png")
									about.get_node("Panel/HBoxContainer/VBoxContainer/Label3").text = "Irís é uma jovem que precisa voltar para casa e descobrirá um mundo totalmente novo"
					3:
						SistemadeSave.save_game()
						print("Jogo Salvo com Sucesso!")
						aviso_save.visible = true
						menu.visible = false
						await get_tree().create_timer(2.0).timeout
						aviso_save.visible = false
						var player = get_tree().get_first_node_in_group("player")
						if player:
							player.set_process(true)
						screen_loaded = ScreenLoaded.NOTHING
					4:
						audio_menu.open()
						menu.visible = false
						screen_loaded = ScreenLoaded.AUDIO_MENU
					5:
						# Salva o personagem atual para restaurá-lo depois se necessário
						var personagem_atual = State.playerAtual
						var tem_outro_save = false
						
						# Lista de todos os personagens possíveis no jogo
						var todos_personagens = ["Milena", "Iris"] # Adicione outros nomes aqui se tiver mais
						
						for personagem in todos_personagens:
							if personagem != personagem_atual:
								State.playerAtual = personagem
								if SistemadeSave.has_save():
									tem_outro_save = true
									break
						
						# Restaura o personagem atual antes de mudar de cena
						State.playerAtual = personagem_atual
						
						# Se achou save de outro personagem, vai para savePersonagens, senão vai para home
						if tem_outro_save:
							get_tree().change_scene_to_file("res://scenes/savePersonagens.tscn")
						else:
							get_tree().change_scene_to_file("res://scenes/home.tscn")
					6:
						_show_quit_confirmation()
			elif event.is_action_pressed("down"):
				selected_option = (selected_option + 1) % 7
				select_arrow.position.y = 5 + selected_option * 77
			elif event.is_action_pressed("up"):
				selected_option = (selected_option - 1 + 7) % 7
				select_arrow.position.y = 5 + selected_option * 77

		ScreenLoaded.PARTY_SCREEN:
			var inventory = get_tree().get_first_node_in_group("Inventory")
			if inventory:
				inventory.get_node("Control").visible = true
				var arrow_inv = inventory.get_node("Control/NinePatchRect/TextureRect")
				select_arrow.visible = false

				const COLS = 4
				const ROWS = 4
				const CELL_SIZE = 54
				const OFFSET_X = 9
				const OFFSET_Y = 7

				if event.is_action_pressed("down"):
					inv_selected = (inv_selected + COLS) % (COLS * ROWS)
				elif event.is_action_pressed("up"):
					inv_selected = (inv_selected - COLS + COLS * ROWS) % (COLS * ROWS)
				elif event.is_action_pressed("right"):
					var row = inv_selected / COLS
					var col = (inv_selected % COLS + 1) % COLS
					inv_selected = row * COLS + col
				elif event.is_action_pressed("left"):
					var row = inv_selected / COLS
					var col = (inv_selected % COLS - 1 + COLS) % COLS
					inv_selected = row * COLS + col
				elif event.is_action_pressed("ataque"):
					var player = get_tree().get_first_node_in_group("player")
					if inv_selected < itens.size() and itens[inv_selected] != null:
						itens[inv_selected].usar(player)
				elif event.is_action_pressed("voltar"):
					inventory.get_node("Control").visible = false
					select_arrow.visible = true
					inv_selected = 0
					screen_loaded = ScreenLoaded.JUST_MENU

				arrow_inv.position.x = OFFSET_X + (inv_selected % COLS) * CELL_SIZE
				arrow_inv.position.y = OFFSET_Y + (inv_selected / COLS) * CELL_SIZE

		ScreenLoaded.AUDIO_MENU:
			pass

func _close_menu():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_process(true)
	menu.visible = false
	audio_menu.visible = false
	if about:
		about.visible = false
	State.menu_aberto = false
	select_arrow.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
	selected_option = 0

func _on_audio_menu_closed() -> void:
	menu.visible = true
	select_arrow.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
