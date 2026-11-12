extends SceneTree
## Menjalankan game dari awal sampai akhir dan menyimpan screenshot tiap langkah:
## home -> pengaturan (bahasa, kecepatan) -> fusion -> telur -> formasi -> battle -> hasil.
## Memakai berkas simpan sendiri berisi naga kembar supaya fusion bisa dicoba.
## Jalankan: xvfb-run -a godot --fixed-fps 60 -s res://tools/capture.gd -- FOLDER

const SAVE := "user://capture_save.json"
const ISI_SAVE := {
	"v": 2, "bahasa": "en", "eggs": ["api"],
	"naga": [
		{"id": "fire_drake", "b": 1}, {"id": "fire_drake", "b": 1},
		{"id": "swamp_drake", "b": 1}, {"id": "forest_drake", "b": 1}, {"id": "ice_dragon", "b": 2},
	],
}
const MAKS_FRAME := 9000

var _f := 0
var _main: Node
var _out := "user://"
var _langkah := 0
var _tunggu := 0
var _shot_battle := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	var f := FileAccess.open(SAVE, FileAccess.WRITE)
	f.store_string(JSON.stringify(ISI_SAVE))
	f.close()
	_main = load("res://src/main.tscn").instantiate()
	_main.save_path = SAVE
	root.add_child(_main)


func _layar() -> Node:
	return _main.get_child(_main.get_child_count() - 1)


func _process(_delta: float) -> bool:
	_f += 1
	if _tunggu > 0:
		_tunggu -= 1
		return false
	match _langkah:
		0:
			_jeda(20)
		1:
			_shot("1-home-en")
			_layar().buka_pengaturan.emit()
			_jeda(15)
		2:
			_shot("2-pengaturan-en")
			_layar().set_bahasa("id")
			_jeda(15)
		3:
			_layar().set_kecepatan(2)
			_jeda(15)
		4:
			_shot("3-pengaturan-id")
			_layar().kembali.emit()
			_jeda(15)
		5:
			_layar().buka_fusion.emit()
			_jeda(20)
		6:
			_shot("4-fusion")
			_layar().gabung("fire_drake", 1)
			_jeda(110)
		7:
			_shot("5-fusion-hasil")
			_layar().kembali.emit()
			_jeda(10)
		8:
			_layar().buka_telur.emit()
			_jeda(20)
		9:
			_shot("6-telur")
			_layar().tetaskan(0)
			_jeda(150)
		10:
			_shot("7-telur-menetas")
			_layar().kembali.emit()
			_jeda(10)
		11:
			_layar().buka_battle.emit()
			_jeda(15)
		12:
			for p in 3:
				_layar().pilih(p)
			_jeda(15)
		13:
			_shot("8-formasi")
			_layar().mulai_battle()
			_jeda(20)
		14:
			if _layar().selesai:
				_jeda(20)
			else:
				_shot_battle += 1
				if _shot_battle <= 6:
					_shot("9-battle-%d" % _shot_battle)
				_langkah -= 1
				_jeda(60)
		15:
			_shot("10-hasil")
			_layar().kembali.emit()
			_jeda(15)
		16:
			_shot("11-home-id")
			return true
	return _f >= MAKS_FRAME

func _jeda(frame: int) -> void:
	_langkah += 1
	_tunggu = frame


func _shot(nama: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(_out.path_join(nama + ".png"))
	print("shot ", nama)
