extends SceneTree
## Tes koleksi dan telur. Jalankan: godot --headless -s res://tests/test_player_state.gd

var _gagal := 0
var _data: GameData


func _init() -> void:
	_data = GameData.load_from("res://data")
	_test_pemain_baru()
	_test_tetas_sesuai_elemen()
	_test_tanpa_kembar_sampai_lengkap()
	_test_simpan_muat()
	_test_data_telur_valid()
	_test_tim_lawan_setara()
	print("HASIL: %s" % ("LULUS" if _gagal == 0 else "%d GAGAL" % _gagal))
	quit(1 if _gagal > 0 else 0)


func _cek(ok: bool, nama: String) -> void:
	print("%s %s" % ["ok  " if ok else "GAGAL", nama])
	if not ok:
		_gagal += 1


func _rng(s: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = s
	return r


func _test_pemain_baru() -> void:
	var s := PlayerState.baru(_data)
	_cek(s.owned.size() == int(_data.battle["ukuran_tim"]), "pemain baru punya naga cukup untuk 1 tim")
	_cek(s.eggs.size() == _data.koleksi["telur_awal"].size(), "pemain baru punya telur awal")


func _test_tetas_sesuai_elemen() -> void:
	var ok := true
	for i in 40:
		var s := PlayerState.baru(_data)
		s.eggs = ["es"]
		var naga := s.tetas(0, _data, _rng(i))
		if naga.is_empty() or naga["elemen"] != "es" or not s.owned.has(naga["id"]) or not s.eggs.is_empty():
			ok = false
	_cek(ok, "telur es selalu menetas jadi naga es dan telurnya habis")


func _test_tanpa_kembar_sampai_lengkap() -> void:
	var s := PlayerState.baru(_data)
	var rng := _rng(5)
	var kembar := false
	for i in _data.dragons.size() + 5:
		s.eggs.append("api")
		var sebelum := s.owned.duplicate()
		var naga := s.tetas(s.eggs.size() - 1, _data, rng)
		if not naga.is_empty() and sebelum.has(naga["id"]):
			kembar = true
	_cek(not kembar, "menetas tidak pernah memberi naga yang sudah dimiliki")
	_cek(s.owned.size() == _data.dragons.size(), "koleksi bisa lengkap: %d/%d" % [s.owned.size(), _data.dragons.size()])
	_cek(not s.bisa_menetas(_data) and s.tetas(0, _data, rng).is_empty(), "koleksi lengkap -> telur tidak menetas")


func _test_simpan_muat() -> void:
	var s := PlayerState.baru(_data)
	s.eggs.append("emas")
	s.tetas(0, _data, _rng(2))
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := PlayerState.from_dict(d, _data)
	_cek(t.owned == s.owned and t.eggs == s.eggs, "simpan -> muat mengembalikan data yang sama")
	var kotor := PlayerState.from_dict({"owned": ["dragon", "tidak_ada", 7, "dragon"], "eggs": ["api", "palsu"]}, _data)
	_cek(kotor.owned == ["dragon"] and kotor.eggs == ["api"], "id tidak dikenal dan kembar dibuang saat muat")
	_cek(PlayerState.muat("user://tidak_ada.json", _data).owned.size() > 0, "berkas simpan tidak ada -> pemain baru")


func _test_data_telur_valid() -> void:
	var ok := true
	for e: Dictionary in _data.koleksi["telur"]:
		if not ResourceLoader.exists(e["sprite"]):
			ok = false
		for el: String in e["elemen"]:
			if not _data.dragons.any(func(d: Dictionary) -> bool: return d["elemen"] == el):
				ok = false
	for id: String in _data.koleksi["naga_awal"]:
		if _data.get_dragon(id).is_empty():
			ok = false
	_cek(ok, "koleksi.json: sprite telur ada, elemen dan naga awal dikenal")
	var semua := true
	for d: Dictionary in _data.dragons:
		if not ResourceLoader.exists(d["sprite"]):
			semua = false
	_cek(semua, "dragons.json: semua sprite naga ada")


func _test_tim_lawan_setara() -> void:
	var tim := [_data.get_dragon("fire_drake"), _data.get_dragon("dragon"), _data.get_dragon("golden_dragon")]
	var ok := true
	for i in 30:
		var lawan := _data.tim_lawan(tim, _rng(i))
		for k in tim.size():
			if lawan[k]["tingkat"] != tim[k]["tingkat"]:
				ok = false
		if lawan[0] == lawan[1] or lawan[1] == lawan[2] or lawan[0] == lawan[2]:
			ok = false
	_cek(ok, "tim lawan: tingkat sama per slot, tanpa naga kembar")
