class_name UiTheme
extends RefCounted
## Tema UI dari aset gambar: panel 9-slice Kenney Pixel UI + font pixel.

const SLICE_DIR := "res://assets/ui/kenney-pixel-ui/9-Slice/"
const FONT_ISI := "res://assets/fonts/Minimal5x7.ttf"
const FONT_JUDUL := "res://assets/fonts/PublicPixel.ttf"
const UKURAN_ISI := 16
const UKURAN_JUDUL := 8
const SLICE_MARGIN := 16


## Bangun tema untuk seluruh UI.
static func build() -> Theme:
	var th := Theme.new()
	th.default_font = font(FONT_ISI)
	th.default_font_size = UKURAN_ISI
	th.set_stylebox("normal", "Button", box("Ancient/tan.png"))
	th.set_stylebox("hover", "Button", box("Ancient/white.png"))
	th.set_stylebox("pressed", "Button", box("Ancient/tan_pressed.png"))
	th.set_stylebox("disabled", "Button", box("Ancient/grey.png"))
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		th.set_color(state, "Button", Color("3b2a1a"))
	th.set_color("font_disabled_color", "Button", Color("5a5a5a"))
	th.set_stylebox("panel", "PanelContainer", box("Ancient/brown.png"))
	th.set_color("font_color", "Label", Color.WHITE)
	th.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.8))
	th.set_constant("shadow_offset_x", "Label", 1)
	th.set_constant("shadow_offset_y", "Label", 1)
	return th


## Muat font pixel tanpa anti-alias supaya tetap tajam.
static func font(path: String) -> FontFile:
	var f: FontFile = load(path)
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting = TextServer.HINTING_NONE
	return f


## StyleBox 9-slice dari berkas di folder Kenney Pixel UI.
static func box(file: String, isi := 6) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load(SLICE_DIR + file)
	sb.set_texture_margin_all(SLICE_MARGIN)
	sb.set_content_margin_all(isi)
	return sb


## Latar layar menu (gambar kuil senja, digelapkan).
static func latar() -> TextureRect:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/bg/kuil-senja/SunsetTempleBackground.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.55, 0.55, 0.6)
	return bg


## Teks bintang, mis. "★★" (atau "*2" bila font tidak punya glif bintang).
static func bintang(n: int) -> String:
	if font(FONT_JUDUL).has_char(0x2605):
		return "★".repeat(n)
	return "*%d" % n


## Label bintang kuning untuk ditempel di atas ikon naga.
static func label_bintang(n: int) -> Label:
	var l := judul(bintang(n))
	l.modulate = Color("ffd23c")
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Label judul dengan font tebal.
static func judul(teks: String) -> Label:
	var l := Label.new()
	l.text = teks
	l.add_theme_font_override("font", font(FONT_JUDUL))
	l.add_theme_font_size_override("font_size", UKURAN_JUDUL)
	return l
