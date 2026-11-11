extends Control
## Alur utama: formasi -> battle -> hadiah telur -> telur menetas -> formasi.

## Lokasi berkas simpan. Alat uji boleh menggantinya sebelum node masuk ke tree.
var save_path := "user://save.json"

var _data: GameData
var _state: PlayerState
var _rng := RandomNumberGenerator.new()
var _layar: Control


func _ready() -> void:
	theme = UiTheme.build()
	_data = GameData.load_from("res://data")
	_state = PlayerState.muat(save_path, _data)
	_rng.randomize()
	_tampil_formasi()


func _tampil_formasi() -> void:
	var f := FormationScreen.new()
	f.setup(_data, _state)
	f.mulai.connect(_mulai_battle)
	f.buka_telur.connect(_tampil_telur)
	_ganti(f)


func _tampil_telur() -> void:
	var e := EggScreen.new()
	e.setup(_data, _state, _rng)
	e.berubah.connect(_state.simpan.bind(save_path))
	e.kembali.connect(_tampil_formasi)
	_ganti(e)


func _mulai_battle(team: Array) -> void:
	var b := BattleView.new()
	b.setup(_data, team, _data.tim_lawan(team, _rng), _rng.randi_range(0, 999999))
	b.menang.connect(_beri_hadiah.bind(b))
	b.kembali.connect(_tampil_formasi)
	_ganti(b)


func _beri_hadiah(b: BattleView) -> void:
	var id := _data.pilih_telur_hadiah(_rng)
	_state.eggs.append(id)
	_state.simpan(save_path)
	b.hadiah = _data.get_egg(id)


func _ganti(layar: Control) -> void:
	if _layar != null:
		_layar.queue_free()
	_layar = layar
	add_child(layar)
