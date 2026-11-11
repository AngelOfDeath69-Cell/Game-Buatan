class_name EggScreen
extends Control
## Layar telur: pilih telur, tonton menetas, dapat naga (boleh kembar untuk fusion).

## Dipancarkan saat pemain menekan Kembali.
signal kembali
## Dipancarkan setelah telur menetas (koleksi berubah, perlu disimpan).
signal berubah

const PUSAT := Vector2(320, 220)
const SKALA := 3.0

var _data: GameData
var _state: PlayerState
var _rng: RandomNumberGenerator
var _daftar: HFlowContainer
var _pesan: Label
var _panggung: Node2D
var _sibuk := false


func setup(data: GameData, state: PlayerState, rng: RandomNumberGenerator) -> void:
	_data = data
	_state = state
	_rng = rng


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar())
	var pita := UiTheme.pita(tr("TELUR_JUDUL"), 200)
	pita.position = Vector2(220, 4)
	add_child(pita)
	var tutup := UiTheme.tombol_bulat("Close")
	tutup.position = Vector2(596, 0)
	tutup.pressed.connect(func() -> void:
		if not _sibuk:
			kembali.emit())
	add_child(tutup)

	var panel := PanelContainer.new()
	panel.position = Vector2(6, 40)
	panel.size = Vector2(628, 100)
	add_child(panel)
	var gulir := ScrollContainer.new()
	gulir.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(gulir)
	_daftar = HFlowContainer.new()
	_daftar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gulir.add_child(_daftar)

	_panggung = Node2D.new()
	add_child(_panggung)

	_pesan = Label.new()
	_pesan.position = Vector2(120, 296)
	_pesan.size = Vector2(400, 40)
	_pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_pesan)

	_segarkan()


## Tetaskan telur ke-[param index] dan mainkan animasinya.
func tetaskan(index: int) -> void:
	if _sibuk or index >= _state.eggs.size():
		return
	var telur := _data.get_egg(_state.eggs[index])
	var hasil := _state.tetas(index, _data, _rng)
	if hasil.is_empty():
		return
	_sibuk = true
	berubah.emit()
	_segarkan()
	await _animasi(telur, _data.stat_naga(hasil))
	_sibuk = false


func _animasi(telur: Dictionary, naga: Dictionary) -> void:
	for c in _panggung.get_children():
		c.queue_free()
	_pesan.text = tr("TELUR_BERGETAR") % GameData.nama(telur)
	var s := Sprite2D.new()
	s.texture = load(telur["sprite"])
	s.scale = Vector2(SKALA, SKALA)
	s.position = PUSAT
	_panggung.add_child(s)
	var t := create_tween()
	for i in 6:
		var d := 0.12 - i * 0.012
		t.tween_property(s, "rotation", 0.22, d)
		t.tween_property(s, "rotation", -0.22, d)
	t.tween_property(s, "rotation", 0.0, 0.05)
	t.tween_property(s, "scale", Vector2(SKALA, SKALA) * 1.4, 0.12)
	t.parallel().tween_property(s, "modulate", Color(3, 3, 3, 0), 0.12)
	await t.finished
	s.queue_free()

	var n := Sprite2D.new()
	n.texture = load(naga["sprite"])
	n.position = PUSAT
	n.scale = Vector2.ZERO
	_panggung.add_child(n)
	var t2 := create_tween()
	t2.tween_property(n, "scale", Vector2(SKALA, SKALA), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t2.finished
	_pesan.text = tr("TELUR_MENETAS") % [naga["nama"], GameData.nama_elemen(naga["elemen"]), int(naga["tingkat"])]


func _segarkan() -> void:
	for c in _daftar.get_children():
		c.queue_free()
	for i in _state.eggs.size():
		var e := _data.get_egg(_state.eggs[i])
		var b := Button.new()
		b.icon = load(e["sprite"])
		b.text = GameData.nama(e)
		b.custom_minimum_size = Vector2(146, 42)
		b.pressed.connect(tetaskan.bind(i))
		_daftar.add_child(b)
	_pesan.text = tr("TELUR_KOSONG") if _state.eggs.is_empty() else tr("TELUR_PETUNJUK")
