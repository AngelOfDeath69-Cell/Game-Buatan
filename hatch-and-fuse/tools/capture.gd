extends SceneTree
## Menjalankan game dari awal sampai akhir dan menyimpan screenshot tiap langkah:
## formasi -> fusion -> telur menetas -> ganti bahasa -> battle -> hasil.
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
			_shot("1-formasi-en")
			_layar().buka_fusion.emit()
			_jeda(20)
		2:
			_shot("2-fusion")
			_layar().gabung("fire_drake", 1)
			_jeda(110)
		3:
			_shot("3-fusion-hasil")
			_layar().kembali.emit()
			_jeda(10)
		4:
			_layar().buka_telur.emit()
			_jeda(20)
		5:
			_layar().tetaskan(0)
			_jeda(150)
		6:
			_shot("4-telur-menetas")
			_layar().kembali.emit()
			_jeda(10)
		7:
			_layar().ganti_bahasa.emit()
			_jeda(20)
		8:
			for p in 3:
				_layar().pilih(p)
			_jeda(15)
		9:
			_shot("5-formasi-id")
			_layar().mulai_battle()
			_jeda(20)
		10:
			if _layar().selesai:
				_jeda(20)
			else:
				_shot_battle += 1
				if _shot_battle <= 6:
					_shot("6-battle-%d" % _shot_battle)
				_langkah -= 1
				_jeda(97)
		11:
			_shot("7-hasil")
			return true
	return _f >= MAKS_FRAME


func _jeda(frame: int) -> void:
	_langkah += 1
	_tunggu = frame


func _shot(nama: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(_out.path_join(nama + ".png"))
	print("shot ", nama)
