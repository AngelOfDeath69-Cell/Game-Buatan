class_name BattleView
extends Control
## Arena auto-battle: memutar event dari [BattleSim] sebagai animasi.
## Pemain hanya menonton; hasil ditentukan formasi dan naga yang dipilih.

## Dipancarkan saat pemain menekan Kembali di panel hasil.
signal kembali
## Dipancarkan sekali saat tim pemain menang, sebelum panel hasil dibuat.
## Pendengar boleh mengisi [member hadiah].
signal menang

const LEBAR := 640.0
const TINGGI_ARENA := 330.0
const SKALA_ARENA := 3.0

## True setelah panel hasil tampil.
var selesai := false
## Data telur hadiah (lihat `koleksi.json`) untuk ditampilkan di panel hasil. {} = tanpa hadiah.
var hadiah: Dictionary = {}

var _data: GameData
var _sim: BattleSim
var _views: Array[UnitView] = []
var _arena: Node2D
var _log: Label
var _vfx_cache: Dictionary = {}
var _tempo := 1.0
var _nama_arena := ""
## Bintang tiap naga: [tim kiri, tim kanan], urut slot.
var team_bintang: Array = [[], []]


## [param team_a]: tim pemain (kiri), [param team_b]: lawan (kanan), urut dari depan.
func setup(data: GameData, team_a: Array, team_b: Array, rng_seed: int, kecepatan := 1) -> void:
	_data = data
	_sim = BattleSim.new(team_a, team_b, data.battle, rng_seed)
	team_bintang = [
		team_a.map(func(d: Dictionary) -> int: return int(d.get("bintang", 1))),
		team_b.map(func(d: Dictionary) -> int: return int(d.get("bintang", 1))),
	]
	var arena_list: Array = data.battle["arena"]
	_nama_arena = arena_list[rng_seed % arena_list.size()]
	_tempo = 1.0 / (float(data.battle["tampil"]["kecepatan"]) * kecepatan)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/bg/arena/%s.png" % _nama_arena)
	bg.centered = false
	bg.scale = Vector2(SKALA_ARENA, SKALA_ARENA)
	bg.position = Vector2((LEBAR - bg.texture.get_width() * SKALA_ARENA) / 2.0, 0)
	add_child(bg)

	_arena = Node2D.new()
	_arena.y_sort_enabled = true
	add_child(_arena)
	var posisi: Array = _data.battle["tampil"]["posisi_tim_kiri"]
	for u in _sim.units:
		var p := Vector2(posisi[u.slot][0], posisi[u.slot][1])
		if u.side == 1:
			p.x = LEBAR - p.x
		var v := UnitView.new()
		_arena.add_child(v)
		v.setup(load(u.sprite), u.side == 0, p)
		_views.append(v)
		var b: int = (team_bintang[u.side][u.slot])
		var lb := UiTheme.baris_bintang(b)
		lb.alignment = BoxContainer.ALIGNMENT_CENTER
		lb.position = Vector2(-30, 2)
		lb.size = Vector2(60, 11)
		v.add_child(lb)

	var strip := NinePatchRect.new()
	strip.texture = load(UiTheme.REGALIA + "20240709dragonButtonB-Sheet.png")
	strip.region_rect = Rect2(312, 0, 104, 35)
	strip.patch_margin_left = 24
	strip.patch_margin_right = 24
	strip.position = Vector2(-10, 325)
	strip.size = Vector2(LEBAR + 20, 35)
	add_child(strip)
	_log = Label.new()
	_log.position = Vector2(8, 333)
	_log.size = Vector2(LEBAR - 16, 20)
	_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_log.text = tr("BATTLE_MULAI")
	add_child(_log)
	_putar()


func _putar() -> void:
	await _tunggu(0.6)
	while not _sim.is_over():
		await _tampil_aksi(_sim.step())
	await _tunggu(0.4)
	_tampil_hasil()


func _tampil_aksi(ev: Dictionary) -> void:
	var aktor: BattleSim.Unit = _sim.units[ev["uid"]]
	var v := _views[aktor.uid]
	var jurus: bool = ev["jenis"] == "jurus"
	if jurus:
		_log.text = tr("BATTLE_JURUS") % [aktor.nama, GameData.nama(_data.battle["jurus"][ev["jurus"]])]
	else:
		_log.text = tr("BATTLE_SERANG") % aktor.nama
	if jurus:
		await v.siap_jurus(0.22 * _tempo)
	await v.maju(0.14 * _tempo)
	v.set_energi(float(aktor.energi) / float(_data.battle["energi_penuh"]))
	for hit: Dictionary in ev["hits"]:
		_tampil_hit(hit, ev)
	await _tunggu(0.55 if jurus else 0.35)
	await v.mundur(0.16 * _tempo)


func _tampil_hit(hit: Dictionary, ev: Dictionary) -> void:
	var t: BattleSim.Unit = _sim.units[hit["uid"]]
	var v := _views[t.uid]
	if ev["vfx"] != "":
		_efek(ev["vfx"], v, Color(str(ev["warna"])))
	match hit["hasil"]:
		"hindar":
			v.hindar(0.4 * _tempo)
			_teks(v, tr("HINDAR"), Color("9be7ff"))
			return
		"blok":
			v.blok(0.35 * _tempo)
			_teks(v, tr("BLOK") % hit["dmg"], Color("7fb0ff"))
		_:
			v.kena(0.3 * _tempo)
			var kuat: bool = hit["efektif"] > 0
			_teks(v, ("%d!" if kuat else "%d") % hit["dmg"], Color("ffd23c") if kuat else Color.WHITE)
	v.set_hp(float(hit["hp"]) / float(t.hp_max))
	v.set_energi(float(t.energi) / float(_data.battle["energi_penuh"]))
	if hit["mati"]:
		v.mati(0.5 * _tempo)


func _teks(v: UnitView, teks: String, warna: Color) -> void:
	var l := UiTheme.judul(teks)
	l.modulate = warna
	l.position = v.tengah() + Vector2(-40, -44)
	l.size = Vector2(80, 10)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - 14, 0.5 * _tempo)
	tw.tween_property(l, "modulate:a", 0.0, 0.2 * _tempo)
	tw.tween_callback(l.queue_free)


func _efek(nama: String, v: UnitView, warna: Color) -> void:
	var cfg: Dictionary = _data.battle["vfx"][nama]
	var s := AnimatedSprite2D.new()
	s.sprite_frames = _frames(nama, cfg)
	var skala: float = cfg["skala"]
	s.scale = Vector2(skala, skala)
	s.modulate = warna
	s.speed_scale = 1.0 / _tempo
	if cfg["jangkar"] == "bawah":
		var tinggi: float = s.sprite_frames.get_frame_texture("main", 0).get_height() * skala
		s.position = v.position + Vector2(0, -tinggi / 2.0 + 4)
	else:
		s.position = v.tengah()
	s.z_index = 10
	add_child(s)
	s.animation_finished.connect(s.queue_free)
	s.play("main")


func _frames(nama: String, cfg: Dictionary) -> SpriteFrames:
	if not _vfx_cache.has(nama):
		var sf := SpriteFrames.new()
		sf.add_animation("main")
		sf.set_animation_loop("main", false)
		sf.set_animation_speed("main", float(cfg["fps"]))
		for i in int(cfg["frame"]):
			sf.add_frame("main", load(str(cfg["pola"]) % (i + 1)))
		_vfx_cache[nama] = sf
	return _vfx_cache[nama]


func _tampil_hasil() -> void:
	var w := _sim.winner()
	var teks := tr("MENANG") if w == 0 else (tr("KALAH") if w == 1 else tr("SERI"))
	_log.text = tr("BATTLE_SELESAI")
	if w == 0:
		menang.emit()
	var panel := PanelContainer.new()
	panel.position = Vector2(190, 96)
	panel.size = Vector2(260, 170)
	var pita := UiTheme.pita(teks, 220, 2)
	pita.position = Vector2(210, 76)
	pita.z_index = 1
	add_child(panel)
	var isi := VBoxContainer.new()
	isi.alignment = BoxContainer.ALIGNMENT_CENTER
	isi.add_theme_constant_override("separation", 6)
	panel.add_child(isi)
	if not hadiah.is_empty():
		var telur := TextureRect.new()
		telur.texture = load(hadiah["sprite"])
		telur.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		isi.add_child(telur)
		var ket := Label.new()
		ket.text = tr("HADIAH") % GameData.nama(hadiah)
		ket.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		isi.add_child(ket)
	var b := Button.new()
	b.text = tr("TOMBOL_OK")
	b.theme_type_variation = "Utama"
	b.custom_minimum_size = Vector2(140, 40)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(func() -> void: kembali.emit())
	isi.add_child(b)
	add_child(pita)
	selesai = true


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik * _tempo).timeout
