extends Control

signal dialogue_finished

@export_file("*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready():
	$NinePatchRect.visible = false
	# Garante que este nó processe input ANTES de outros (ex: NPCs)
	process_priority = -100

func start():
	if d_active:
		return
	d_active = true
	dialogue = load_dialogue()
	if dialogue.is_empty():
		d_active = false
		return
	current_dialogue_id = -1
	$NinePatchRect.visible = true
	next_script()

func load_dialogue():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.podeAndar = 0
	if d_file == null or d_file == "":
		print("Erro: arquivo de diálogo não definido.")
		return []
	var file = FileAccess.open(d_file, FileAccess.READ)
	if file == null:
		print("Erro ao abrir arquivo: ", d_file)
		return []
	var text = file.get_as_text()
	var content = JSON.parse_string(text)
	if content == null:
		print("Erro ao parsear JSON.")
		return []
	return content

func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		next_script()
		# impede que outros nós (ex: NPC) recebam este mesmo evento
		get_viewport().set_input_as_handled()

func next_script():
	current_dialogue_id += 1
	print("next_script chamado, id=", current_dialogue_id)

	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text']
	$NinePatchRect/Sprite2D.texture = load("res://icons/" + dialogue[current_dialogue_id]['icon'])

	if current_dialogue_id >= (len(dialogue) - 1):
		d_active = false
		$NinePatchRect.hide()
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.podeAndar = 1
		
		await get_tree().create_timer(1.0).timeout
		var npc =  get_tree().get_first_node_in_group("npc")
		if npc:
			npc.perm = 1
		emit_signal("dialogue_finished")
		print("cabo")
		return
