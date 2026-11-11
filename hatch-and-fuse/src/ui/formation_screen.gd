class_name FormationScreen
extends Control
## Layar pilih naga dan formasi. Pemain memilih 3 naga miliknya: depan, tengah, belakang.

## Dipancarkan saat pemain menekan Mulai. [param team]: Array data battle naga
## (lihat [method GameData.stat_naga]) urut dari depan.
signal mulai(team: Array)
## Dipancarkan saat pemain menekan tombol Telur.
signal buka_telur
## Dipancarkan saat pemain menekan tombol Fusion.
signal buka_fusion
## Dipancarkan saat pemain menekan tombol bahasa.
signal ganti_bahasa

const JUMLAH_SLOT := 3
const KOLOM := 8
const SEL := Vector2(46, 42)

var _data: GameData
var _state: PlayerState
## Indeks ke `_state.naga`, urut tampil (bintang tertinggi dulu).
var _urut: Array[int] = []
## Naga terpilih sebagai posisi di `_urut`.
var _team: Array[int] = []
var _tombol_naga: Array[Button] = []
var _tombol_slot: Array[Button] = []
var _tombol_mulai: Button
var _info: Label


func setup(data: GameData, state: PlayerState) -> void:
	_data = data
	_state = state


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar())

	var judul := UiTheme.judul(tr("FORMASI_JUDUL") % [_state.jumlah_jenis(), _data.dragons.size()])
	judul.position = Vector2(12, 8)
	add_child(judul)

	var kisi_panel := PanelContainer.new()
	kisi_panel.position = Vector2(8, 24)
	kisi_panel.size = Vector2(396, 328)
	add_child(kisi_panel)
	var gulir := ScrollContainer.new()
	gulir.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	kisi_panel.add_child(gulir)
	var kisi := GridContainer.new()
	kisi.columns = KOLOM
	kisi.add_theme_constant_override("h_separation", 1)
	kisi.add_theme_constant_override("v_separation", 1)
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
		b.icon = load(d["sprite"])
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = SEL
		b.pressed.connect(pilih.bind(p))
		b.mouse_entered.connect(_tampil_info.bind(d))
		if d["bintang"] > 1:
			var lb := UiTheme.label_bintang(d["bintang"])
			lb.position = Vector2(3, 2)
			b.add_child(lb)
		kisi.add_child(b)
		_tombol_naga.append(b)

	for i in JUMLAH_SLOT:
		var s := Button.new()
		s.position = Vector2(412, 24 + i * 55)
		s.size = Vector2(220, 52)
		s.alignment = HORIZONTAL_ALIGNMENT_LEFT
		s.pressed.connect(lepas.bind(i))
		add_child(s)
		_tombol_slot.append(s)

	_info = Label.new()
	_info.position = Vector2(416, 188)
	_info.size = Vector2(212, 46)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_info)

	var telur := _tombol(tr("TOMBOL_TELUR") % _state.eggs.size(), Rect2(412, 236, 108, 34), buka_telur)
	if not _state.eggs.is_empty():
		telur.icon = load(_data.get_egg(_state.eggs[0])["sprite"])
		telur.expand_icon = true
	_tombol(tr("TOMBOL_FUSION"), Rect2(524, 236, 108, 34), buka_fusion)
	_tombol(tr("TOMBOL_BAHASA"), Rect2(412, 272, 220, 32), ganti_bahasa)

	_tombol_mulai = Button.new()
	_tombol_mulai.text = tr("TOMBOL_MULAI")
	_tombol_mulai.position = Vector2(412, 306)
	_tombol_mulai.size = Vector2(220, 46)
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


func _tombol(teks: String, kotak: Rect2, sinyal: Signal) -> Button:
	var b := Button.new()
	b.text = teks
	b.position = kotak.position
	b.size = kotak.size
	b.pressed.connect(func() -> void: sinyal.emit())
	add_child(b)
	return b


func _segarkan() -> void:
	for p in _tombol_naga.size():
		_tombol_naga[p].disabled = _team.has(p)
	for i in _tombol_slot.size():
		var s := _tombol_slot[i]
		var nama_slot := tr("SLOT_%d" % i)
		if i < _team.size():
			var d := _stat(_team[i])
			s.icon = load(d["sprite"])
			s.text = "%s\n%s %s" % [nama_slot, d["nama"], UiTheme.bintang(d["bintang"])]
		else:
			s.icon = null
			s.text = "%s\n%s" % [nama_slot, tr("KOSONG")]
	_tombol_mulai.disabled = _team.size() < JUMLAH_SLOT
	if _team.is_empty():
		_info.text = tr("PETUNJUK_FORMASI")


func _tampil_info(d: Dictionary) -> void:
	_info.text = tr("INFO_NAGA") % [
		d["nama"], UiTheme.bintang(d["bintang"]), GameData.nama_elemen(d["elemen"]), int(d["tingkat"]),
		int(d["hp"]), int(d["atk"]), int(d["def"]), int(d["spd"]),
	]
