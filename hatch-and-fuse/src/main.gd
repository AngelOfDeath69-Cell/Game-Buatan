extends Control
## Alur utama: Home -> (formasi -> battle -> hadiah telur) / telur / fusion / pengaturan.

## Lokasi berkas simpan. Alat uji boleh menggantinya sebelum node masuk ke tree.
var save_path := "user://save.json"

var _data: GameData
var _state: PlayerState
var _rng := RandomNumberGenerator.new()
var _layar: Control


func _ready() -> void:
	theme = UiTheme.build()
	_data = GameData.load_from("res://data")
	_data.pasang_bahasa()
	var ada_simpanan := FileAccess.file_exists(save_path)
	_state = PlayerState.muat(save_path, _data)
	if not ada_simpanan and OS.get_locale_language() == "id":
		_state.bahasa = "id"
	TranslationServer.set_locale(_state.bahasa)
	_rng.randomize()
	_tampil_home()


func _tampil_home() -> void:
	var h := HomeScreen.new()
	h.setup(_data, _state)
	h.buka_battle.connect(_tampil_formasi)
	h.buka_telur.connect(_tampil_telur)
	h.buka_fusion.connect(_tampil_fusion)
	h.buka_pengaturan.connect(_tampil_pengaturan)
	_ganti(h)


func _tampil_formasi() -> void:
	var f := FormationScreen.new()
	f.setup(_data, _state)
	f.mulai.connect(_mulai_battle)
	f.kembali.connect(_tampil_home)
	_ganti(f)


func _tampil_telur() -> void:
	var e := EggScreen.new()
	e.setup(_data, _state, _rng)
	e.berubah.connect(_state.simpan.bind(save_path))
	e.kembali.connect(_tampil_home)
	_ganti(e)


func _tampil_fusion() -> void:
	var f := FusionScreen.new()
	f.setup(_data, _state)
	f.berubah.connect(_state.simpan.bind(save_path))
	f.kembali.connect(_tampil_home)
	_ganti(f)


func _tampil_pengaturan() -> void:
	var s := SettingsScreen.new()
	s.setup(_state)
	s.berubah.connect(func() -> void:
		_state.simpan(save_path)
		_tampil_pengaturan())
	s.kembali.connect(_tampil_home)
	_ganti(s)


func _mulai_battle(team: Array) -> void:
	var b := BattleView.new()
	b.setup(_data, team, _data.tim_lawan(team, _rng), _rng.randi_range(0, 999999), _state.kecepatan)
	b.menang.connect(_beri_hadiah.bind(b))
	b.kembali.connect(_tampil_home)
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
