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


## [param team_a]: tim pemain (kiri), [param team_b]: lawan (kanan), urut dari depan.
func setup(data: GameData, team_a: Array, team_b: Array, rng_seed: int) -> void:
	_data = data
	_sim = BattleSim.new(team_a, team_b, data.battle, rng_seed)
	var arena_list: Array = data.battle["arena"]
	_nama_arena = arena_list[rng_seed % arena_list.size()]
	_tempo = 1.0 / float(data.battle["tampil"]["kecepatan"])


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

	var strip := ColorRect.new()
	strip.color = Color("1b1420")
	strip.position = Vector2(0, TINGGI_ARENA)
	strip.size = Vector2(LEBAR, 360 - TINGGI_ARENA)
	add_child(strip)
	_log = Label.new()
	_log.position = Vector2(8, TINGGI_ARENA + 6)
	_log.size = Vector2(LEBAR - 16, 20)
	_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_log.text = "Battle dimulai!"
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
	_log.text = "%s: %s!" % [aktor.nama, ev["nama"]] if jurus else "%s menyerang" % aktor.nama
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
			_teks(v, "HINDAR", Color("9be7ff"))
			return
		"blok":
			v.blok(0.35 * _tempo)
			_teks(v, "BLOK %d" % hit["dmg"], Color("7fb0ff"))
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
	l.position = v.tengah() + Vector2(-24, -44)
	l.size = Vector2(48, 10)
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
	var teks := "MENANG!" if w == 0 else ("KALAH" if w == 1 else "SERI")
	_log.text = "Battle selesai"
	if w == 0:
		menang.emit()
	var panel := PanelContainer.new()
	panel.position = Vector2(200, 90)
	panel.size = Vector2(240, 150)
	add_child(panel)
	var isi := VBoxContainer.new()
	isi.alignment = BoxContainer.ALIGNMENT_CENTER
	isi.add_theme_constant_override("separation", 6)
	panel.add_child(isi)
	var judul := UiTheme.judul(teks)
	judul.add_theme_font_size_override("font_size", UiTheme.UKURAN_JUDUL * 2)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.modulate = Color("ffd23c") if w == 0 else Color.WHITE
	isi.add_child(judul)
	if not hadiah.is_empty():
		var telur := TextureRect.new()
		telur.texture = load(hadiah["sprite"])
		telur.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		isi.add_child(telur)
		var ket := Label.new()
		ket.text = "+1 %s" % hadiah["nama"]
		ket.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		isi.add_child(ket)
	var b := Button.new()
	b.text = "KEMBALI"
	b.custom_minimum_size = Vector2(120, 36)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(func() -> void: kembali.emit())
	isi.add_child(b)
	selesai = true


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik * _tempo).timeout
