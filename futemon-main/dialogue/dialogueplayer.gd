extends Control

signal dialogue_finished

@export_file("*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready():
	$NinePatchRect.visible = false

func start():
	if d_active:
		return
	d_active = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	$NinePatchRect.visible = true
	next_script()

func load_dialogue():
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
	if event.is_action_pressed("ui_accept"):
		next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.hide()
		emit_signal("dialogue_finished")
		return

	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text']
