extends SceneTree
## Tes koleksi, telur, fusion, dan teks. Jalankan: godot --headless -s res://tests/test_player_state.gd

var _gagal := 0
var _data: GameData


func _init() -> void:
	_data = GameData.load_from("res://data")
	_data.pasang_bahasa()
	_test_pemain_baru()
	_test_tetas_sesuai_elemen()
	_test_tetas_bisa_kembar()
	_test_fusion()
	_test_bintang_menambah_stat()
	_test_simpan_muat()
	_test_data_valid()
	_test_dua_bahasa()
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


func _state(ids: Array) -> PlayerState:
	return PlayerState.from_dict({"owned": ids, "eggs": []}, _data)


func _test_pemain_baru() -> void:
	var s := PlayerState.baru(_data)
	_cek(s.naga.size() == int(_data.battle["ukuran_tim"]), "pemain baru punya naga cukup untuk 1 tim")
	_cek(s.eggs.size() == _data.koleksi["telur_awal"].size(), "pemain baru punya telur awal")


func _test_tetas_sesuai_elemen() -> void:
	var ok := true
	for i in 40:
		var s := PlayerState.baru(_data)
		s.eggs = ["es"]
		var n := s.tetas(0, _data, _rng(i))
		if n.is_empty() or _data.get_dragon(n["id"])["elemen"] != "es" or n["b"] != 1 or not s.eggs.is_empty():
			ok = false
		if s.naga.size() != 4:
			ok = false
	_cek(ok, "telur es -> naga es bintang 1, telur habis, naga bertambah 1")
	_cek(PlayerState.baru(_data).tetas(5, _data, _rng(1)).is_empty(), "indeks telur salah -> tidak menetas")


func _test_tetas_bisa_kembar() -> void:
	var s := PlayerState.baru(_data)
	var rng := _rng(3)
	for i in 60:
		s.eggs.append("api")
		s.tetas(s.eggs.size() - 1, _data, rng)
	_cek(s.naga.size() == 63 and s.jumlah_jenis() < s.naga.size(), "menetas bisa memberi naga kembar (%d ekor, %d jenis)" % [s.naga.size(), s.jumlah_jenis()])
	_cek(not s.kelompok_fusion(_data).is_empty(), "naga kembar membentuk kelompok fusion")


func _test_fusion() -> void:
	var s := _state(["dragon", "dragon", "dragon", "ice_dragon"])
	var k := s.kelompok_fusion(_data)
	_cek(k.size() == 1 and k[0]["id"] == "dragon" and k[0]["jumlah"] == 3, "kelompok fusion hanya naga kembar")
	var h := s.fusion("dragon", 1, _data)
	_cek(h == {"id": "dragon", "b": 2} and s.naga.size() == 3, "2 naga bintang 1 -> 1 naga bintang 2")
	_cek(s.fusion("dragon", 1, _data).is_empty() and s.naga.size() == 3, "sisa 1 ekor tidak bisa fusion")
	_cek(s.fusion("ice_dragon", 1, _data).is_empty(), "naga tunggal tidak bisa fusion")
	_cek(s.fusion("dragon", 2, _data).is_empty(), "bintang beda tidak bisa fusion")
	var maks := int(_data.koleksi["maks_bintang"])
	var t := PlayerState.from_dict({"naga": [{"id": "dragon", "b": maks}, {"id": "dragon", "b": maks}]}, _data)
	_cek(t.fusion("dragon", maks, _data).is_empty() and t.kelompok_fusion(_data).is_empty(), "bintang maksimal tidak bisa fusion")


func _test_bintang_menambah_stat() -> void:
	var a := _data.stat_naga({"id": "dragon", "b": 1})
	var b := _data.stat_naga({"id": "dragon", "b": 3})
	var kali := 1.0 + float(_data.koleksi["bonus_bintang"]) * 2
	var dasar := _data.get_dragon("dragon")
	_cek(a["hp"] == int(dasar["hp"]) and a["atk"] == int(dasar["atk"]), "bintang 1 = stat dasar")
	_cek(b["hp"] == roundi(dasar["hp"] * kali) and b["atk"] == roundi(dasar["atk"] * kali) and b["spd"] == dasar["spd"], "bintang 3: HP %d -> %d, SPD tetap" % [a["hp"], b["hp"]])
	_cek(int(dasar["hp"]) == a["hp"] and _data.get_dragon("dragon")["hp"] == dasar["hp"], "stat_naga tidak mengubah data dasar")


func _test_simpan_muat() -> void:
	var s := _state(["dragon", "dragon", "ice_dragon"])
	s.fusion("dragon", 1, _data)
	s.eggs.append("emas")
	s.bahasa = "id"
	s.kecepatan = 2
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := PlayerState.from_dict(d, _data)
	_cek(t.naga == s.naga and t.eggs == s.eggs and t.bahasa == "id" and t.kecepatan == 2, "simpan -> muat mengembalikan data yang sama")
	var lama := PlayerState.from_dict({"owned": ["dragon", "tidak_ada", 7], "eggs": ["api", "palsu"]}, _data)
	_cek(lama.naga == [{"id": "dragon", "b": 1}] and lama.eggs == ["api"], "berkas simpan lama terbaca, entri tidak dikenal dibuang")
	var kotor := PlayerState.from_dict({"naga": [{"id": "dragon", "b": 99}, {"id": "x", "b": 1}, 3], "bahasa": "xx"}, _data)
	_cek(kotor.naga == [{"id": "dragon", "b": int(_data.koleksi["maks_bintang"])}] and kotor.bahasa == "en" and kotor.kecepatan == 1, "bintang dibatasi, naga/bahasa tidak dikenal dibuang")
	var kuat := PlayerState.from_dict({"naga": [{"id": "golden_dragon", "b": 1}, {"id": "fire_drake", "b": 3}, {"id": "dragon", "b": 1}]}, _data)
	_cek(kuat.naga_terkuat(_data)["id"] == "fire_drake", "naga terkuat = bintang tertinggi")
	_cek(PlayerState.muat("user://tidak_ada.json", _data).naga.size() > 0, "berkas simpan tidak ada -> pemain baru")


func _test_data_valid() -> void:
	var ok := true
	for e: Dictionary in _data.koleksi["telur"]:
		if not ResourceLoader.exists(e["sprite"]) or not e.has("nama_en"):
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
		if not ResourceLoader.exists(d["sprite"]) or not d.has("nama_en"):
			semua = false
	_cek(semua, "dragons.json: semua sprite ada, semua punya nama Inggris")


func _test_dua_bahasa() -> void:
	var en: Dictionary = _data.teks["en"]
	var id: Dictionary = _data.teks["id"]
	var kunci_en := en.keys()
	var kunci_id := id.keys()
	kunci_en.sort()
	kunci_id.sort()
	_cek(kunci_en == kunci_id and not kunci_en.is_empty(), "teks.json: kunci sama di en dan id (%d)" % kunci_en.size())
	var elemen_ok := true
	for d: Dictionary in _data.dragons:
		if not en.has("ELEMEN_" + str(d["elemen"])):
			elemen_ok = false
	_cek(elemen_ok, "semua elemen punya nama di teks.json")
	TranslationServer.set_locale("en")
	var a: String = _data.stat_naga({"id": "ice_dragon", "b": 1})["nama"] + "|" + GameData.nama_elemen("es") + "|" + TranslationServer.translate("MENANG")
	TranslationServer.set_locale("id")
	var b: String = _data.stat_naga({"id": "ice_dragon", "b": 1})["nama"] + "|" + GameData.nama_elemen("es") + "|" + TranslationServer.translate("MENANG")
	_cek(a == "Ice Dragon|Ice|VICTORY!" and b == "Naga Es|Es|MENANG!", "ganti bahasa mengubah teks: %s / %s" % [a, b])
	TranslationServer.set_locale("en")


func _test_tim_lawan_setara() -> void:
	var tim := [
		_data.stat_naga({"id": "fire_drake", "b": 1}),
		_data.stat_naga({"id": "dragon", "b": 3}),
		_data.stat_naga({"id": "golden_dragon", "b": 2}),
	]
	var ok := true
	for i in 30:
		var lawan := _data.tim_lawan(tim, _rng(i))
		var ids := {}
		for k in tim.size():
			if lawan[k]["tingkat"] != tim[k]["tingkat"] or lawan[k]["bintang"] != tim[k]["bintang"]:
				ok = false
			ids[lawan[k]["id"]] = true
		if ids.size() != tim.size():
			ok = false
	_cek(ok, "tim lawan: tingkat dan bintang sama per slot, tanpa naga kembar")
