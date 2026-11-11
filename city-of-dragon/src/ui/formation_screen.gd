class_name FormationScreen
extends Control
## Layar pilih naga dan formasi. Pemain memilih 3 naga: depan, tengah, belakang.

## Dipancarkan saat pemain menekan Mulai. [param team]: Array data naga urut dari depan.
signal mulai(team: Array)

const NAMA_SLOT := ["DEPAN", "TENGAH", "BELAKANG"]
const KOLOM := 8
const SEL := Vector2(46, 42)

var _data: GameData
var _team: Array = []
var _tombol_naga: Dictionary = {}
var _tombol_slot: Array[Button] = []
var _tombol_mulai: Button
var _info: Label


func setup(data: GameData) -> void:
	_data = data


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/bg/kuil-senja/SunsetTempleBackground.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.55, 0.55, 0.6)
	add_child(bg)

	var judul := UiTheme.judul("PILIH 3 NAGA")
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
	for d: Dictionary in _data.dragons:
		var b := Button.new()
		b.icon = load(d["sprite"])
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = SEL
		b.pressed.connect(pilih.bind(d["id"]))
		b.mouse_entered.connect(_tampil_info.bind(d))
		kisi.add_child(b)
		_tombol_naga[d["id"]] = b

	for i in NAMA_SLOT.size():
		var s := Button.new()
		s.position = Vector2(412, 24 + i * 62)
		s.size = Vector2(220, 58)
		s.alignment = HORIZONTAL_ALIGNMENT_LEFT
		s.pressed.connect(lepas.bind(i))
		add_child(s)
		_tombol_slot.append(s)

	_info = Label.new()
	_info.position = Vector2(416, 212)
	_info.size = Vector2(212, 84)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_info)

	_tombol_mulai = Button.new()
	_tombol_mulai.text = "MULAI BATTLE"
	_tombol_mulai.position = Vector2(412, 310)
	_tombol_mulai.size = Vector2(220, 42)
	_tombol_mulai.pressed.connect(mulai_battle)
	add_child(_tombol_mulai)
	_segarkan()


## Masukkan naga ke slot kosong berikutnya.
func pilih(id: String) -> void:
	var d := _data.get_dragon(id)
	if d.is_empty() or _team.has(d) or _team.size() >= NAMA_SLOT.size():
		return
	_team.append(d)
	_tampil_info(d)
	_segarkan()


## Keluarkan naga dari slot [param i].
func lepas(i: int) -> void:
	if i < _team.size():
		_team.remove_at(i)
		_segarkan()


## Mulai battle bila tim sudah lengkap.
func mulai_battle() -> void:
	if _team.size() == NAMA_SLOT.size():
		mulai.emit(_team.duplicate())


func _segarkan() -> void:
	for id: String in _tombol_naga:
		var b: Button = _tombol_naga[id]
		b.disabled = _team.has(_data.get_dragon(id))
	for i in _tombol_slot.size():
		var s := _tombol_slot[i]
		if i < _team.size():
			var d: Dictionary = _team[i]
			s.icon = load(d["sprite"])
			s.text = "%s\n%s (%s)" % [NAMA_SLOT[i], d["nama"], str(d["elemen"]).capitalize()]
		else:
			s.icon = null
			s.text = "%s\n(kosong)" % NAMA_SLOT[i]
	_tombol_mulai.disabled = _team.size() < NAMA_SLOT.size()
	if _team.is_empty():
		_info.text = "Klik naga untuk mengisi formasi. Naga DEPAN diserang lebih dulu."


func _tampil_info(d: Dictionary) -> void:
	_info.text = "%s\nElemen %s  Tingkat %d\nHP %d  ATK %d\nDEF %d  SPD %d" % [
		d["nama"], str(d["elemen"]).to_upper(), int(d["tingkat"]),
		int(d["hp"]), int(d["atk"]), int(d["def"]), int(d["spd"]),
	]
