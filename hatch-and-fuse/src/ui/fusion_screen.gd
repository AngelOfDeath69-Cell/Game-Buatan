class_name FusionScreen
extends Control
## Layar fusion: dua naga sama berbintang sama digabung jadi satu naga bintang+1.

## Dipancarkan saat pemain menekan Kembali.
signal kembali
## Dipancarkan setelah fusion (koleksi berubah, perlu disimpan).
signal berubah

const PUSAT := Vector2(320, 190)
const JARAK := 110.0
const SKALA := 3.0

var _data: GameData
var _state: PlayerState
var _daftar: HFlowContainer
var _pesan: Label
var _panggung: Node2D
var _sibuk := false


func setup(data: GameData, state: PlayerState) -> void:
	_data = data
	_state = state


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar())
	var judul := UiTheme.judul(tr("FUSION_JUDUL"))
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
	_pesan.position = Vector2(100, 262)
	_pesan.size = Vector2(440, 40)
	_pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pesan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_pesan)

	var b := Button.new()
	b.text = tr("TOMBOL_KEMBALI")
	b.position = Vector2(260, 310)
	b.size = Vector2(120, 42)
	b.pressed.connect(func() -> void:
		if not _sibuk:
			kembali.emit())
	add_child(b)
	_segarkan()


## Gabungkan dua naga [param id] berbintang [param b] dan mainkan animasinya.
func gabung(id: String, b: int) -> void:
	if _sibuk:
		return
	var hasil := _state.fusion(id, b, _data)
	if hasil.is_empty():
		return
	_sibuk = true
	berubah.emit()
	_segarkan()
	await _animasi(_data.stat_naga(hasil))
	_sibuk = false


func _animasi(naga: Dictionary) -> void:
	for c in _panggung.get_children():
		c.queue_free()
	_pesan.text = tr("FUSION_PROSES") % naga["nama"]
	var tex: Texture2D = load(naga["sprite"])
	var kiri := _sprite(tex, PUSAT + Vector2(-JARAK, 0), true)
	var kanan := _sprite(tex, PUSAT + Vector2(JARAK, 0), false)
	var t := create_tween()
	t.tween_property(kiri, "position", PUSAT, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(kanan, "position", PUSAT, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(kiri, "modulate", Color(3, 3, 3, 0), 0.15)
	t.parallel().tween_property(kanan, "modulate", Color(3, 3, 3, 0), 0.15)
	await t.finished
	kiri.queue_free()
	kanan.queue_free()

	var n := _sprite(tex, PUSAT, false)
	n.scale = Vector2.ZERO
	var lb := UiTheme.label_bintang(naga["bintang"])
	lb.position = PUSAT + Vector2(-50, 54)
	lb.size = Vector2(100, 10)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panggung.add_child(lb)
	var t2 := create_tween()
	t2.tween_property(n, "scale", Vector2(SKALA, SKALA) * 1.15, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t2.finished
	_pesan.text = tr("FUSION_HASIL") % [naga["nama"], UiTheme.bintang(naga["bintang"])]


func _sprite(tex: Texture2D, pos: Vector2, balik: bool) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.scale = Vector2(SKALA, SKALA)
	s.flip_h = balik
	s.position = pos
	_panggung.add_child(s)
	return s


func _segarkan() -> void:
	for c in _daftar.get_children():
		c.queue_free()
	var kelompok := _state.kelompok_fusion(_data)
	for k: Dictionary in kelompok:
		var d := _data.stat_naga(k)
		var b := Button.new()
		b.icon = load(d["sprite"])
		b.text = "%s %s x%d" % [d["nama"], UiTheme.bintang(d["bintang"]), k["jumlah"]]
		b.custom_minimum_size = Vector2(150, 42)
		b.pressed.connect(gabung.bind(k["id"], k["b"]))
		_daftar.add_child(b)
	_pesan.text = tr("FUSION_KOSONG") if kelompok.is_empty() else tr("FUSION_PETUNJUK")
