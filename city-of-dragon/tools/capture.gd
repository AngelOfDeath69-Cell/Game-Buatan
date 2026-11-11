extends SceneTree
## Menjalankan game dari awal sampai akhir dan menyimpan screenshot tiap langkah:
## formasi -> telur menetas -> battle -> hasil. Memakai berkas simpan sendiri.
## Jalankan: xvfb-run -a godot --fixed-fps 60 -s res://tools/capture.gd -- FOLDER

const SAVE := "user://capture_save.json"
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
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(SAVE)
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
			_shot("1-formasi-awal")
			_layar().buka_telur.emit()
			_jeda(20)
		2:
			_shot("2-telur")
			_layar().tetaskan(0)
			_jeda(45)
		3:
			_shot("3-telur-bergetar")
			_jeda(120)
		4:
			_shot("4-naga-baru")
			_layar().kembali.emit()
			_jeda(20)
		5:
			var f := _layar()
			for d: Dictionary in f._state.naga_dimiliki(f._data).slice(0, 3):
				f.pilih(d["id"])
			_jeda(15)
		6:
			_shot("5-formasi-terisi")
			_layar().mulai_battle()
			_jeda(20)
		7:
			if _layar().selesai:
				_jeda(20)
			else:
				_shot_battle += 1
				if _shot_battle <= 6:
					_shot("6-battle-%d" % _shot_battle)
				_langkah -= 1
				_jeda(97)
		8:
			_shot("7-hasil")
			_layar().kembali.emit()
			_jeda(20)
		9:
			_shot("8-formasi-akhir")
			return true
	return _f >= MAKS_FRAME


func _jeda(frame: int) -> void:
	_langkah += 1
	_tunggu = frame


func _shot(nama: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(_out.path_join(nama + ".png"))
	print("shot ", nama)
