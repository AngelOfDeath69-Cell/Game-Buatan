class_name EggScreen
extends Control
## Layar telur: pilih telur, tonton menetas, dapat naga baru.

## Dipancarkan saat pemain menekan Kembali.
signal kembali
## Dipancarkan setelah telur menetas (koleksi berubah, perlu disimpan).
signal berubah

const PUSAT := Vector2(320, 190)
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
	var bg := TextureRect.new()
	bg.texture = load("res://assets/bg/kuil-senja/SunsetTempleBackground.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.55, 0.55, 0.6)
	add_child(bg)

	var judul := UiTheme.judul("TELUR")
	judul.position = Vector2(12, 8)
	add_child(judul)

	var panel := PanelContainer.new()
	panel.position = Vector2(8, 24)
	panel.size = Vector2(624, 96)
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
	_pesan.position = Vector2(120, 262)
	_pesan.size = Vector2(400, 40)
	_pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_pesan)

	var b := Button.new()
	b.text = "KEMBALI"
	b.position = Vector2(260, 310)
	b.size = Vector2(120, 42)
	b.pressed.connect(func() -> void:
		if not _sibuk:
			kembali.emit())
	add_child(b)
	_segarkan()


## Tetaskan telur ke-[param index] dan mainkan animasinya.
func tetaskan(index: int) -> void:
	if _sibuk or index >= _state.eggs.size():
		return
	var telur := _data.get_egg(_state.eggs[index])
	var naga := _state.tetas(index, _data, _rng)
	if naga.is_empty():
		return
	_sibuk = true
	berubah.emit()
	_segarkan()
	await _animasi(telur, naga)
	_sibuk = false


func _animasi(telur: Dictionary, naga: Dictionary) -> void:
	for c in _panggung.get_children():
		c.queue_free()
	_pesan.text = "%s bergetar..." % telur["nama"]
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
	_pesan.text = "NAGA BARU: %s\nElemen %s  Tingkat %d" % [
		naga["nama"], str(naga["elemen"]).capitalize(), int(naga["tingkat"])]


func _segarkan() -> void:
	for c in _daftar.get_children():
		c.queue_free()
	for i in _state.eggs.size():
		var e := _data.get_egg(_state.eggs[i])
		var b := Button.new()
		b.icon = load(e["sprite"])
		b.text = e["nama"]
		b.custom_minimum_size = Vector2(120, 42)
		b.disabled = not _state.bisa_menetas(_data)
		b.pressed.connect(tetaskan.bind(i))
		_daftar.add_child(b)
	if _state.eggs.is_empty():
		_pesan.text = "Belum ada telur. Menangkan battle untuk mendapat telur."
	elif not _state.bisa_menetas(_data):
		_pesan.text = "Koleksi lengkap! Semua naga sudah kamu miliki."
	else:
		_pesan.text = "Klik telur untuk menetaskannya."
