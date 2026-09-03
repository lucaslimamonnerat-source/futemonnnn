extends CanvasLayer
@onready var select_arrow = $Control/NinePatchRect/TextureRect
@onready var menu = $Control
enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN}
var screen_loaded = ScreenLoaded.NOTHING
var selected_option: int = 0
var inv_selected: int = 0
var itens: Array = []

func _ready() -> void:
	menu.visible = false
	select_arrow.position.y = 18 + (selected_option % 5) * 77

	# Popula o inventário — edita aqui com seus itens
	var item_vel = ItemVelocidade.new()
	var item_cor = ItemCor.new()
	itens = [item_vel, item_cor, null, null,
			 null, null, null, null,
			 null, null, null, null,
			 null, null, null, null]

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				var player = get_tree().get_first_node_in_group("player")
				if !player.moving:
					player.set_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				selected_option = 0
				select_arrow.position.y = 5

		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu") or event.is_action_pressed("voltar"):
				var player = get_tree().get_first_node_in_group("player")
				player.set_process(true)
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
				selected_option = 0
				
			# ACESSAR A MOCHILA (Opção 1)
			elif event.is_action_pressed("ataque") and selected_option == 1:
				var inventory = get_tree().get_first_node_in_group("Inventory")
				inventory.get_node("Control").visible = true
				inv_selected = 0
				var arrow_inv = inventory.get_node("Control/NinePatchRect/TextureRect")
				arrow_inv.position = Vector2(0, 0)
				screen_loaded = ScreenLoaded.PARTY_SCREEN
				
			# SALVAR O JOGO (Opção 3)
			elif event.is_action_pressed("ataque") and selected_option == 3:
				SistemadeSave.save_game()
				print("Jogo Salvo com Sucesso!") 
				
				# --- FEEDBACK VISUAL ---
				# Pega o Label que você criou
				var aviso = $AvisoSave 
				aviso.visible = true # Faz o texto aparecer na tela
				
				# Cria um cronômetro de 2 segundos que pausa essa linha de código
				await get_tree().create_timer(2.0).timeout 
				
				aviso.visible = false # Faz o texto sumir de novo
				
			# FECHAR O JOGO / SAÍDA (Opção 4)
			elif event.is_action_pressed("ataque") and selected_option == 4:
				get_tree().quit() # Fecha o jogo
				
			# NAVEGAÇÃO DO MENU (Para baixo e Para cima)
			elif event.is_action_pressed("down"):
				selected_option += 1
				select_arrow.position.y = 5 + (selected_option % 5) * 77
			elif event.is_action_pressed("up"):
				if selected_option == 0:
					selected_option = 4
				else:
					selected_option -= 1
				select_arrow.position.y = 5 + (selected_option % 5) * 77

		ScreenLoaded.PARTY_SCREEN:
			var inventory = get_tree().get_first_node_in_group("Inventory")
			inventory.get_node("Control").visible = true
			select_arrow.visible = false
			var arrow_inv = inventory.get_node("Control/NinePatchRect/TextureRect")

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
