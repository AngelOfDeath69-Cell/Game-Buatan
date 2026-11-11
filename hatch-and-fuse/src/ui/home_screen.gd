class_name HomeScreen
extends Control
## Layar utama: judul, naga terkuat pemain, dan menu Battle / Telur / Fusion.
## Tombol pengaturan ada di pojok kanan atas.

signal buka_battle
signal buka_telur
signal buka_fusion
signal buka_pengaturan

const JUDUL_GAME := "HATCH & FUSE"
const SUBJUDUL := "DRAGON ARENA"
const SKALA_NAGA := 4.0

var _data: GameData
var _state: PlayerState


func setup(data: GameData, state: PlayerState) -> void:
	_data = data
	_state = state


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar(0.85))

	var pita := UiTheme.pita(JUDUL_GAME, 300, 2)
	pita.position = Vector2(170, 10)
	add_child(pita)
	var sub := UiTheme.judul(SUBJUDUL)
	sub.position = Vector2(170, 46)
	sub.size = Vector2(300, 10)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = UiTheme.WARNA_EMAS
	add_child(sub)

	var atur := UiTheme.tombol_bulat("Options")
	atur.position = Vector2(596, 4)
	atur.pressed.connect(func() -> void: buka_pengaturan.emit())
	add_child(atur)

	var d := _state.naga_terkuat(_data)
	var naga := Sprite2D.new()
	naga.texture = load(d["sprite"])
	naga.scale = Vector2(SKALA_NAGA, SKALA_NAGA)
	naga.flip_h = true
	naga.position = Vector2(190, 200)
	add_child(naga)
	var napas := naga.create_tween().set_loops()
	napas.tween_property(naga, "position:y", 194.0, 0.9).set_trans(Tween.TRANS_SINE)
	napas.tween_property(naga, "position:y", 200.0, 0.9).set_trans(Tween.TRANS_SINE)
	var nama := Label.new()
	nama.text = d["nama"]
	nama.position = Vector2(90, 272)
	nama.size = Vector2(200, 16)
	nama.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(nama)
	var bintang := UiTheme.baris_bintang(d["bintang"])
	bintang.alignment = BoxContainer.ALIGNMENT_CENTER
	bintang.position = Vector2(90, 290)
	bintang.size = Vector2(200, 11)
	add_child(bintang)

	_menu(tr("HOME_BATTLE"), 100, buka_battle, "Utama")
	var telur := _menu(tr("TOMBOL_TELUR") % _state.eggs.size(), 156, buka_telur, "")
	if not _state.eggs.is_empty():
		telur.icon = load(_data.get_egg(_state.eggs[0])["sprite"])
		telur.expand_icon = true
	_menu(tr("TOMBOL_FUSION"), 212, buka_fusion, "")

	var koleksi := Label.new()
	koleksi.text = tr("HOME_KOLEKSI") % [_state.jumlah_jenis(), _data.dragons.size()]
	koleksi.position = Vector2(380, 272)
	koleksi.size = Vector2(220, 16)
	koleksi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(koleksi)


func _menu(teks: String, y: float, sinyal: Signal, variasi: String) -> Button:
	var b := Button.new()
	b.text = teks
	b.theme_type_variation = variasi
	b.position = Vector2(380, y)
	b.size = Vector2(220, 48)
	b.pressed.connect(func() -> void: sinyal.emit())
	add_child(b)
	return b
