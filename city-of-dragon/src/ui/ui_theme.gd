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


## Label judul dengan font tebal.
static func judul(teks: String) -> Label:
	var l := Label.new()
	l.text = teks
	l.add_theme_font_override("font", font(FONT_JUDUL))
	l.add_theme_font_size_override("font_size", UKURAN_JUDUL)
	return l
