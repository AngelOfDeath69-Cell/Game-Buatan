class_name FormationScreen
extends Control
## Layar persiapan battle: pemain memilih 3 naga miliknya (depan, tengah, belakang).

## Dipancarkan saat pemain menekan Mulai. [param team]: Array data battle naga
## (lihat [method GameData.stat_naga]) urut dari depan.
signal mulai(team: Array)
## Dipancarkan saat pemain menutup layar.
signal kembali

const JUMLAH_SLOT := 3
const KOLOM := 8
const SEL := Vector2(44, 44)

var _data: GameData
var _state: PlayerState
## Indeks ke `_state.naga`, urut tampil (bintang tertinggi dulu).
var _urut: Array[int] = []
## Naga terpilih sebagai posisi di `_urut`.
var _team: Array[int] = []
var _tombol_naga: Array[Button] = []
var _tombol_slot: Array[Button] = []
var _bintang_slot: Array[Control] = []
var _tombol_mulai: Button
var _info: Label


func setup(data: GameData, state: PlayerState) -> void:
	_data = data
	_state = state


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar())
	var pita := UiTheme.pita(tr("FORMASI_JUDUL"), 260)
	pita.position = Vector2(190, 4)
	add_child(pita)
	var tutup := UiTheme.tombol_bulat("Close")
	tutup.position = Vector2(596, 0)
	tutup.pressed.connect(func() -> void: kembali.emit())
	add_child(tutup)

	var kisi_panel := PanelContainer.new()
	kisi_panel.position = Vector2(6, 40)
	kisi_panel.size = Vector2(398, 314)
	add_child(kisi_panel)
	var gulir := ScrollContainer.new()
	gulir.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	kisi_panel.add_child(gulir)
	var kisi := GridContainer.new()
	kisi.columns = KOLOM
	kisi.add_theme_constant_override("h_separation", 2)
	kisi.add_theme_constant_override("v_separation", 2)
	gulir.add_child(kisi)

	for i in _state.naga.size():
		_urut.append(i)
	var posisi := {}
	for i in _data.dragons.size():
		posisi[_data.dragons[i]["id"]] = i
	_urut.sort_custom(func(a: int, b: int) -> bool:
		var na := _state.naga[a]
		var nb := _state.naga[b]
		if na["b"] != nb["b"]:
			return na["b"] > nb["b"]
		if na["id"] != nb["id"]:
			return posisi[na["id"]] < posisi[nb["id"]]
		return a < b)
	for p in _urut.size():
		var d := _stat(p)
		var b := Button.new()
		b.theme_type_variation = "Sel"
		b.icon = load(d["sprite"])
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = SEL
		b.pressed.connect(pilih.bind(p))
		b.mouse_entered.connect(_tampil_info.bind(d))
		var bintang := UiTheme.baris_bintang(d["bintang"])
		bintang.position = Vector2(2, 1)
		b.add_child(bintang)
		kisi.add_child(b)
		_tombol_naga.append(b)

	for i in JUMLAH_SLOT:
		var s := Button.new()
		s.position = Vector2(410, 40 + i * 52)
		s.size = Vector2(224, 50)
		s.alignment = HORIZONTAL_ALIGNMENT_LEFT
		s.pressed.connect(lepas.bind(i))
		add_child(s)
		_tombol_slot.append(s)
		var wadah := Control.new()
		wadah.position = Vector2(150, 6)
		wadah.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.add_child(wadah)
		_bintang_slot.append(wadah)

	_info = Label.new()
	_info.position = Vector2(414, 198)
	_info.size = Vector2(216, 60)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_info)

	_tombol_mulai = Button.new()
	_tombol_mulai.theme_type_variation = "Utama"
	_tombol_mulai.text = tr("TOMBOL_MULAI")
	_tombol_mulai.position = Vector2(410, 304)
	_tombol_mulai.size = Vector2(224, 50)
	_tombol_mulai.pressed.connect(mulai_battle)
	add_child(_tombol_mulai)
	_segarkan()


## Masukkan naga di posisi tampil [param p] ke slot kosong berikutnya.
func pilih(p: int) -> void:
	if p < 0 or p >= _urut.size() or _team.has(p) or _team.size() >= JUMLAH_SLOT:
		return
	_team.append(p)
	_tampil_info(_stat(p))
	_segarkan()


## Keluarkan naga dari slot [param i].
func lepas(i: int) -> void:
	if i < _team.size():
		_team.remove_at(i)
		_segarkan()


## Mulai battle bila tim sudah lengkap.
func mulai_battle() -> void:
	if _team.size() == JUMLAH_SLOT:
		var team: Array = []
		for p in _team:
			team.append(_stat(p))
		mulai.emit(team)


func _stat(p: int) -> Dictionary:
	return _data.stat_naga(_state.naga[_urut[p]])


func _segarkan() -> void:
	for p in _tombol_naga.size():
		_tombol_naga[p].disabled = _team.has(p)
	for i in _tombol_slot.size():
		var s := _tombol_slot[i]
		for c in _bintang_slot[i].get_children():
			c.queue_free()
		var nama_slot := tr("SLOT_%d" % i)
		if i < _team.size():
			var d := _stat(_team[i])
			s.icon = load(d["sprite"])
			s.text = "%s\n%s" % [nama_slot, d["nama"]]
			_bintang_slot[i].add_child(UiTheme.baris_bintang(d["bintang"]))
		else:
			s.icon = null
			s.text = "%s\n%s" % [nama_slot, tr("KOSONG")]
	_tombol_mulai.disabled = _team.size() < JUMLAH_SLOT
	if _team.is_empty():
		_info.text = tr("PETUNJUK_FORMASI")


func _tampil_info(d: Dictionary) -> void:
	_info.text = tr("INFO_NAGA") % [
		d["nama"], GameData.nama_elemen(d["elemen"]), int(d["tingkat"]), int(d["bintang"]),
		int(d["hp"]), int(d["atk"]), int(d["def"]), int(d["spd"]),
	]
