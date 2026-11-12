class_name SettingsScreen
extends Control
## Layar pengaturan, terpisah dari permainan: bahasa dan kecepatan battle.

## Dipancarkan saat pemain menutup layar.
signal kembali
## Dipancarkan setelah sebuah pengaturan berubah (perlu disimpan dan layar dibangun ulang).
signal berubah

const NAMA_BAHASA := {"en": "English", "id": "Indonesia"}

var _state: PlayerState


func setup(state: PlayerState) -> void:
	_state = state


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiTheme.latar())
	var pita := UiTheme.pita(tr("SETTING_JUDUL"), 240)
	pita.position = Vector2(200, 10)
	add_child(pita)
	var tutup := UiTheme.tombol_bulat("Close")
	tutup.position = Vector2(596, 4)
	tutup.pressed.connect(func() -> void: kembali.emit())
	add_child(tutup)

	var panel := PanelContainer.new()
	panel.position = Vector2(120, 56)
	panel.size = Vector2(400, 250)
	add_child(panel)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 6)
	panel.add_child(isi)

	isi.add_child(_label(tr("SETTING_BAHASA")))
	var baris_bahasa := HBoxContainer.new()
	isi.add_child(baris_bahasa)
	for kode: String in GameData.BAHASA:
		baris_bahasa.add_child(_pilihan(NAMA_BAHASA[kode], _state.bahasa == kode, set_bahasa.bind(kode)))

	isi.add_child(_label(tr("SETTING_KECEPATAN")))
	var baris_cepat := HBoxContainer.new()
	isi.add_child(baris_cepat)
	for k: int in [1, 2]:
		baris_cepat.add_child(_pilihan("x%d" % k, _state.kecepatan == k, set_kecepatan.bind(k)))

	var versi := _label(tr("SETTING_VERSI") % str(ProjectSettings.get_setting("application/config/version", "")))
	versi.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	versi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	isi.add_child(versi)


## Ganti bahasa antarmuka ke [param kode] ("en" atau "id").
func set_bahasa(kode: String) -> void:
	if _state.bahasa != kode:
		_state.bahasa = kode
		TranslationServer.set_locale(kode)
		berubah.emit()


## Ganti kecepatan animasi battle ke [param k] (1 atau 2).
func set_kecepatan(k: int) -> void:
	if _state.kecepatan != k:
		_state.kecepatan = k
		berubah.emit()


func _label(teks: String) -> Label:
	var l := Label.new()
	l.text = teks
	return l


func _pilihan(teks: String, aktif: bool, aksi: Callable) -> Button:
	var b := Button.new()
	b.text = teks
	b.custom_minimum_size = Vector2(120, 40)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.theme_type_variation = "Utama" if aktif else ""
	b.pressed.connect(aksi)
	return b
