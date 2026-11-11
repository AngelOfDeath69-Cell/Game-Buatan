extends Control
## Alur utama: layar formasi -> battle -> kembali ke formasi.

var _data: GameData
var _rng := RandomNumberGenerator.new()
var _layar: Control


func _ready() -> void:
	theme = UiTheme.build()
	_data = GameData.load_from("res://data")
	_rng.randomize()
	_tampil_formasi()


func _tampil_formasi() -> void:
	var f := FormationScreen.new()
	f.setup(_data)
	f.mulai.connect(_mulai_battle)
	_ganti(f)


func _mulai_battle(team: Array) -> void:
	var b := BattleView.new()
	b.setup(_data, team, _data.random_team(_rng), _rng.randi_range(0, 999999))
	b.kembali.connect(_tampil_formasi)
	_ganti(b)


func _ganti(layar: Control) -> void:
	if _layar != null:
		_layar.queue_free()
	_layar = layar
	add_child(layar)
