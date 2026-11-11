extends SceneTree
## Menjalankan game, memilih tim, menonton satu battle, dan menyimpan screenshot.
## Jalankan: xvfb-run -a godot --fixed-fps 60 -s res://tools/capture.gd -- <folder_keluaran>

const TIM := ["ice_dragon", "storm_dragon", "golden_dragon"]
const JEDA_SHOT := 97
const MAKS_FRAME := 7200

var _f := 0
var _main: Node
var _out := "user://"
var _battle: Node
var _n := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	_main = load("res://src/main.tscn").instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_f += 1
	if _f == 20:
		_shot("1-formasi-kosong")
	elif _f == 21:
		for id: String in TIM:
			_main.get_child(0).pilih(id)
	elif _f == 40:
		_shot("2-formasi-terisi")
	elif _f == 41:
		_main.get_child(0).mulai_battle()
	elif _f == 44:
		_battle = _main.get_child(_main.get_child_count() - 1)
	elif _f > 44 and _battle != null:
		if _battle.selesai:
			if _n < 100:
				_n = 100
				_f = MAKS_FRAME - 20
			elif _f == MAKS_FRAME - 5:
				_shot("4-hasil")
				return true
		elif (_f - 44) % JEDA_SHOT == 0 and _n < 6:
			_n += 1
			_shot("3-battle-%d" % _n)
	return _f >= MAKS_FRAME


func _shot(nama: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(_out.path_join(nama + ".png"))
	print("shot ", nama, " ", img.get_size())
