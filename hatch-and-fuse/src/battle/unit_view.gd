class_name UnitView
extends Node2D
## Tampilan satu naga di arena. Sprite sumber hanya 1 frame; semua gerak
## (napas, maju, hindar, blok, kena, mati) dibuat dengan tween.

const SKALA := 2.0
const LEBAR_BAR := 46.0
const BAR := Vector2(LEBAR_BAR - 10, 4)
const JARAK_MAJU := 30.0
const JARAK_HINDAR := 22.0

var _sprite: Sprite2D
var _hp_isi: ColorRect
var _en_isi: ColorRect
var _arah := 1.0
var _asal: Vector2
var _tinggi := 0.0


## [param menghadap_kanan]: true untuk tim kiri. Sprite sumber menghadap kiri.
func setup(tex: Texture2D, menghadap_kanan: bool, posisi: Vector2) -> void:
	_arah = 1.0 if menghadap_kanan else -1.0
	_asal = posisi
	position = posisi
	_tinggi = tex.get_height() * SKALA
	_sprite = Sprite2D.new()
	_sprite.texture = tex
	_sprite.scale = Vector2(SKALA, SKALA)
	_sprite.flip_h = menghadap_kanan
	_sprite.offset = Vector2(0, -tex.get_height() / 2.0)
	add_child(_sprite)
	_hp_isi = UiTheme.bar(self, Vector2(-LEBAR_BAR / 2, -_tinggi - 16), LEBAR_BAR, Color("3ddc5a"))
	_en_isi = ColorRect.new()
	_en_isi.color = Color("ffd23c")
	_en_isi.position = Vector2(-BAR.x / 2, -_tinggi - 3)
	_en_isi.size = Vector2(BAR.x, 2)
	add_child(_en_isi)
	set_energi(0.0)
	var napas := create_tween().set_loops()
	napas.tween_interval(randf() * 0.4)
	napas.tween_property(_sprite, "position:y", -2.0, 0.45).set_trans(Tween.TRANS_SINE)
	napas.tween_property(_sprite, "position:y", 0.0, 0.45).set_trans(Tween.TRANS_SINE)


## Titik tengah badan, untuk efek dan angka damage.
func tengah() -> Vector2:
	return position + Vector2(0, -_tinggi / 2.0)


func set_hp(rasio: float) -> void:
	_hp_isi.size.x = BAR.x * clampf(rasio, 0.0, 1.0)
	_hp_isi.color = Color("3ddc5a") if rasio > 0.35 else Color("e8483c")


func set_energi(rasio: float) -> void:
	_en_isi.size.x = BAR.x * clampf(rasio, 0.0, 1.0)


## Maju menyerang.
func maju(durasi: float) -> void:
	var t := create_tween()
	t.tween_property(self, "position:x", _asal.x + _arah * JARAK_MAJU, durasi).set_trans(Tween.TRANS_BACK)
	await t.finished


## Kembali ke posisi formasi.
func mundur(durasi: float) -> void:
	var t := create_tween()
	t.tween_property(self, "position", _asal, durasi)
	await t.finished


## Mengumpulkan tenaga sebelum jurus.
func siap_jurus(durasi: float) -> void:
	var t := create_tween()
	t.tween_property(_sprite, "scale", Vector2(SKALA, SKALA) * 1.25, durasi)
	t.parallel().tween_property(_sprite, "modulate", Color(1.4, 1.4, 0.8), durasi)
	t.tween_property(_sprite, "scale", Vector2(SKALA, SKALA), durasi * 0.5)
	t.parallel().tween_property(_sprite, "modulate", Color.WHITE, durasi * 0.5)
	await t.finished


## Kena serangan: memerah dan bergetar.
func kena(durasi: float) -> void:
	_sprite.modulate = Color(1.0, 0.25, 0.25)
	var t := create_tween()
	for i in 3:
		t.tween_property(self, "position:x", _asal.x - _arah * 4.0, durasi / 8.0)
		t.tween_property(self, "position:x", _asal.x, durasi / 8.0)
	t.tween_property(_sprite, "modulate", Color.WHITE, durasi / 4.0)


## Menghindar: melompat mundur dan memudar sebentar.
func hindar(durasi: float) -> void:
	var t := create_tween()
	t.tween_property(self, "position:x", _asal.x - _arah * JARAK_HINDAR, durasi * 0.3)
	t.parallel().tween_property(_sprite, "modulate:a", 0.35, durasi * 0.3)
	t.tween_interval(durasi * 0.3)
	t.tween_property(self, "position:x", _asal.x, durasi * 0.4)
	t.parallel().tween_property(_sprite, "modulate:a", 1.0, durasi * 0.4)


## Memblok: bertahan di tempat dengan kilat biru.
func blok(durasi: float) -> void:
	_sprite.modulate = Color(0.5, 0.8, 1.6)
	var t := create_tween()
	t.tween_property(self, "position:x", _asal.x - _arah * 3.0, durasi * 0.2)
	t.tween_property(self, "position:x", _asal.x, durasi * 0.3)
	t.tween_property(_sprite, "modulate", Color.WHITE, durasi * 0.5)


## Mati: jatuh dan menghilang.
func mati(durasi: float) -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, durasi)
	t.parallel().tween_property(_sprite, "position:y", 8.0, durasi)
	t.parallel().tween_property(_sprite, "rotation", -_arah * 0.6, durasi)

