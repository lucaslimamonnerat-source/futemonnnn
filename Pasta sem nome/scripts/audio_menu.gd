extends CanvasLayer

signal closed

@onready var select_arrow: TextureRect = $Control/NinePatchRect/TextureRect
@onready var label_music: RichTextLabel = $Control/NinePatchRect/VBoxContainer/RichTextLabel
@onready var label_sfx: RichTextLabel = $Control/NinePatchRect/VBoxContainer/RichTextLabel2

const OPTION_COUNT := 6
const ARROW_STEP := 104
const ARROW_START_Y := 16
const ARROW_START_X := 0

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

const RADIO_BOB_ESPONJA := "res://musics/spongebob-squarepants-music.mp3"
const RADIO_NARUTO := "res://musics/naruto-sadness-and-sorrow-classical.mp3"
const RADIO_FUTEMON := "res://musics/aimmeucuzinhopreto.mp3"

var is_open := false
var selected_option := 0

# Volume de 0 a 10
var music_volume := 10
var sfx_volume := 10

func _ready() -> void:
	visible = false

	_set_bus_volume(MUSIC_BUS, music_volume)
	_set_bus_volume(SFX_BUS, sfx_volume)

func open() -> void:
	is_open = true
	visible = true
	State.audiomenu_aberto = true

	selected_option = 0
	select_arrow.position.y = ARROW_START_Y

	_refresh_labels()

func close() -> void:
	is_open = false
	visible = false
	State.audiomenu_aberto = false

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

	# Aumentar volume
	elif event.is_action_pressed("right"):
		match selected_option:
			0:
				music_volume = min(music_volume + 1, 10)
				_set_bus_volume(MUSIC_BUS, music_volume)

			1:
				sfx_volume = min(sfx_volume + 1, 10)
				_set_bus_volume(SFX_BUS, sfx_volume)

		_refresh_labels()
		get_viewport().set_input_as_handled()

	# Diminuir volume
	elif event.is_action_pressed("left"):
		match selected_option:
			0:
				music_volume = max(music_volume - 1, 0)
				_set_bus_volume(MUSIC_BUS, music_volume)

			1:
				sfx_volume = max(sfx_volume - 1, 0)
				_set_bus_volume(SFX_BUS, sfx_volume)

		_refresh_labels()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ataque"):
		get_viewport().set_input_as_handled()

		match selected_option:
			2:
				_play_radio(RADIO_BOB_ESPONJA)

			3:
				_play_radio(RADIO_NARUTO)

			4:
				_play_radio(RADIO_FUTEMON)

			5:
				close()
				closed.emit()

func _set_bus_volume(bus_name: String, value: int) -> void:
	var idx = AudioServer.get_bus_index(bus_name)

	if idx == -1:
		push_warning("Bus '%s' não encontrado." % bus_name)
		return

	value = clamp(value, 0, 10)

	AudioServer.set_bus_mute(idx, value == 0)

	var db = lerpf(-40.0, 0.0, float(value) / 10.0)
	AudioServer.set_bus_volume_db(idx, db)

func _refresh_labels() -> void:
	label_music.text = "Musica: %d" % music_volume
	label_sfx.text = "Efeitos Sonoros: %d" % sfx_volume

func _play_radio(path: String) -> void:
	var music_player = get_tree().get_first_node_in_group("music_player")

	if not music_player:
		push_warning("Nenhum node no grupo 'music_player' encontrado.")
		return

	if music_player.stream and music_player.stream.resource_path == path:
		return

	music_player.stop()
	music_player.stream = load(path)
	music_player.play()
