class_name UiTheme
extends RefCounted
## Kit UI dari aset gambar "Dragon Regalia GUI" (CC0): tombol, panel, pita judul,
## tombol bulat, bingkai sel, bintang. Hanya isi bar (HP/energi) yang berupa kotak warna.

const REGALIA := "res://assets/ui/dragon-regalia/"
const FONT_ISI := "res://assets/fonts/Minimal5x7.ttf"
const FONT_JUDUL := "res://assets/fonts/PublicPixel.ttf"
const UKURAN_ISI := 16
const UKURAN_JUDUL := 8
const BINTANG := "res://assets/ui/ikon/bintang.png"
const WARNA_TEKS := Color("fff4d6")
const WARNA_EMAS := Color("ffd23c")


## Bangun tema untuk seluruh UI.
static func build() -> Theme:
	var th := Theme.new()
	th.default_font = font(FONT_ISI)
	th.default_font_size = UKURAN_ISI
	# Tombol biasa: bingkai emas (4 frame 100x35: normal, sorot, tekan, mati).
	_gaya_tombol(th, "Button", "20240709dragonButtonA-Sheet.png", Vector2i(100, 35), [0, 1, 2, 3], 16, 8)
	# Tombol utama: bingkai batu, isi oranye.
	th.set_type_variation("Utama", "Button")
	_gaya_tombol(th, "Utama", "20240709dragonButtonB-Sheet.png", Vector2i(104, 35), [1, 0, 2, 3], 24, 8)
	# Sel naga: bingkai kotak 32x32 (normal, sorot, tekan, mati).
	th.set_type_variation("Sel", "Button")
	_gaya_tombol(th, "Sel", "20240713dragonFilledFrame-Sheet.png", Vector2i(32, 32), [0, 1, 2, 3], 6, 6)
	var panel := StyleBoxTexture.new()
	panel.texture = load(REGALIA + "20240707dragon9SlicesB.png")
	panel.set_texture_margin_all(24)
	panel.set_content_margin_all(12)
	panel.modulate_color = Color(0.78, 0.8, 0.92)
	th.set_stylebox("panel", "PanelContainer", panel)
	th.set_color("font_color", "Label", WARNA_TEKS)
	th.set_color("font_shadow_color", "Label", Color(0.1, 0.05, 0.2, 0.9))
	th.set_constant("shadow_offset_x", "Label", 1)
	th.set_constant("shadow_offset_y", "Label", 1)
	return th


static func _gaya_tombol(th: Theme, tipe: String, berkas: String, frame: Vector2i, urut: Array, tepi_x: int, tepi_y: int) -> void:
	var tex: Texture2D = load(REGALIA + berkas)
	var nama := ["normal", "hover", "pressed", "disabled"]
	for i in nama.size():
		var sb := StyleBoxTexture.new()
		sb.texture = tex
		sb.region_rect = Rect2(int(urut[i]) * frame.x, 0, frame.x, frame.y)
		sb.set_texture_margin(SIDE_LEFT, tepi_x)
		sb.set_texture_margin(SIDE_RIGHT, tepi_x)
		sb.set_texture_margin(SIDE_TOP, tepi_y)
		sb.set_texture_margin(SIDE_BOTTOM, tepi_y)
		sb.set_content_margin(SIDE_LEFT, tepi_x)
		sb.set_content_margin(SIDE_RIGHT, tepi_x)
		sb.set_content_margin(SIDE_TOP, 6)
		sb.set_content_margin(SIDE_BOTTOM, 7)
		th.set_stylebox(nama[i], tipe, sb)
	th.set_stylebox("focus", tipe, StyleBoxEmpty.new())
	for warna in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		th.set_color(warna, tipe, WARNA_TEKS)
	th.set_color("font_disabled_color", tipe, Color("b9b2cf"))
	th.set_color("font_outline_color", tipe, Color("2a1740"))
	th.set_constant("outline_size", tipe, 2)
	th.set_font("font", tipe, font(FONT_JUDUL))
	th.set_font_size("font_size", tipe, UKURAN_JUDUL)


## Muat font pixel tanpa anti-alias supaya tetap tajam.
static func font(path: String) -> FontFile:
	var f: FontFile = load(path)
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting = TextServer.HINTING_NONE
	return f


## Label judul dengan font tebal.
static func judul(teks: String, kali := 1) -> Label:
	var l := Label.new()
	l.text = teks
	l.add_theme_font_override("font", font(FONT_JUDUL))
	l.add_theme_font_size_override("font_size", UKURAN_JUDUL * kali)
	return l


## Latar layar menu (gambar kuil senja).
static func latar(terang := 0.6) -> TextureRect:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/bg/kuil-senja/SunsetTempleBackground.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(terang, terang, terang + 0.05)
	return bg


## Pita judul (gambar banner) dengan teks di tengah. Tinggi tetap 32.
static func pita(teks: String, lebar: float, kali := 1) -> Control:
	var akar := Control.new()
	akar.size = Vector2(lebar, 32)
	akar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var np := NinePatchRect.new()
	np.texture = load(REGALIA + "20240707dragonHeaderA.png")
	np.patch_margin_left = 24
	np.patch_margin_right = 24
	np.size = akar.size
	akar.add_child(np)
	var l := judul(teks, kali)
	l.size = Vector2(lebar, 24)
	l.position = Vector2(0, 1)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	akar.add_child(l)
	return akar


## Tombol bulat bergambar. [param jenis]: "Options", "Close", "Help", atau "Exit".
## Area sentuh 40x40, gambar 24x24 di tengah.
static func tombol_bulat(jenis: String) -> TextureButton:
	var sheet: Texture2D = load(REGALIA + "20240713dragon%sButton-Sheet.png" % jenis)
	var b := TextureButton.new()
	var frame: Array[AtlasTexture] = []
	for i in 4:
		var a := AtlasTexture.new()
		a.atlas = sheet
		a.region = Rect2(i * 24, 0, 24, 24)
		frame.append(a)
	b.texture_normal = frame[0]
	b.texture_hover = frame[1]
	b.texture_pressed = frame[2]
	b.texture_disabled = frame[3]
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	b.size = Vector2(40, 40)
	return b


## Deretan ikon bintang (gambar), untuk ditempel di atas ikon naga atau di samping nama.
static func baris_bintang(n: int) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", -2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = load(BINTANG)
	for i in n:
		var t := TextureRect.new()
		t.texture = tex
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(t)
	return h


## Bingkai bar (gambar) dengan isi berwarna di belakangnya. Mengembalikan isi bar
## (ColorRect) yang lebarnya diatur pemanggil; lebar penuh = `lebar - 10`.
static func bar(induk: Node, pos: Vector2, lebar: float, warna: Color) -> ColorRect:
	var dasar := ColorRect.new()
	dasar.color = Color("231531")
	dasar.position = pos + Vector2(4, 3)
	dasar.size = Vector2(lebar - 8, 7)
	induk.add_child(dasar)
	var isi := ColorRect.new()
	isi.color = warna
	isi.position = pos + Vector2(5, 4)
	isi.size = Vector2(lebar - 10, 5)
	induk.add_child(isi)
	var np := NinePatchRect.new()
	np.texture = load(REGALIA + "20240709dragonBarA.png")
	np.patch_margin_left = 8
	np.patch_margin_right = 8
	np.draw_center = false
	np.position = pos
	np.size = Vector2(lebar, 13)
	induk.add_child(np)
	return isi
