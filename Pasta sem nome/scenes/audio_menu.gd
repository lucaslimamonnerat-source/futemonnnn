extends CanvasLayer

signal closed

@onready var select_arrow: TextureRect = $Control/NinePatchRect/TextureRect
@onready var label_music: RichTextLabel = $Control/NinePatchRect/VBoxContainer/RichTextLabel
@onready var label_sfx: RichTextLabel = $Control/NinePatchRect/VBoxContainer/RichTextLabel2

const OPTION_COUNT := 5
const ARROW_STEP := 104
const ARROW_START_Y := 65

# ajuste esses nomes pra bater com os buses que você tem na aba "Áudio"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

# ajuste os caminhos dos arquivos de rádio
const RADIO_BOB_ESPONJA := "res://musics/spongebob-squarepants-music.mp3"
const RADIO_NARUTO := "res://musics/naruto-sadness-and-sorrow-classical.mp3"

var is_open := false
var selected_option := 0

func _ready() -> void:
	visible = false

func open() -> void:
	is_open = true
	visible = true
	selected_option = 0
	select_arrow.position.y = ARROW_START_Y
	_refresh_toggle_labels()

func close() -> void:
	is_open = false
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if event.is_action_pressed("voltar") or event.is_action_pressed("menu"):
		close()
		closed.emit()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("down"):
		selected_option = (selected_option + 1) % OPTION_COUNT
		select_arrow.position.y = ARROW_START_Y + selected_option * ARROW_STEP
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("up"):
		selected_option = (selected_option - 1 + OPTION_COUNT) % OPTION_COUNT
		select_arrow.position.y = ARROW_START_Y + selected_option * ARROW_STEP
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ataque"):
		get_viewport().set_input_as_handled()
		match selected_option:
			0: _toggle_music()
			1: _toggle_sfx()
			2: _play_radio(RADIO_BOB_ESPONJA)
			3: _play_radio(RADIO_NARUTO)
			4:
				close()
				closed.emit()

func _toggle_music() -> void:
	var idx := AudioServer.get_bus_index(MUSIC_BUS)
	if idx == -1:
		push_warning("Bus de áudio '%s' não encontrado." % MUSIC_BUS)
		return
	var muted := not AudioServer.is_bus_mute(idx)
	AudioServer.set_bus_mute(idx, muted)
	_update_toggle_label(label_music, "Musica", muted)

func _toggle_sfx() -> void:
	var idx := AudioServer.get_bus_index(SFX_BUS)
	if idx == -1:
		push_warning("Bus de áudio '%s' não encontrado." % SFX_BUS)
		return
	var muted := not AudioServer.is_bus_mute(idx)
	AudioServer.set_bus_mute(idx, muted)
	_update_toggle_label(label_sfx, "Efeitos Sonoros", muted)

func _refresh_toggle_labels() -> void:
	var music_idx := AudioServer.get_bus_index(MUSIC_BUS)
	if music_idx != -1:
		_update_toggle_label(label_music, "Musica", AudioServer.is_bus_mute(music_idx))
	var sfx_idx := AudioServer.get_bus_index(SFX_BUS)
	if sfx_idx != -1:
		_update_toggle_label(label_sfx, "Efeitos Sonoros", AudioServer.is_bus_mute(sfx_idx))

func _update_toggle_label(label: RichTextLabel, base_text: String, muted: bool) -> void:
	label.text = "%s: %s" % [base_text, "Desligado" if muted else "Ligado"]

func _play_radio(path: String) -> void:
	var music_player = get_tree().get_first_node_in_group("music_player")
	if not music_player:
		push_warning("Nenhum node no grupo 'music_player' encontrado.")
		return
	if music_player.stream and music_player.stream.resource_path == path:
		return # já tocando essa música, não faz nada
	music_player.stop()
	music_player.stream = load(path)
	music_player.play()
