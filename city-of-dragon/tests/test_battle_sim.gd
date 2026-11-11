extends SceneTree
## Tes logika battle. Jalankan: godot --headless -s res://tests/test_battle_sim.gd

const SEED_COUNT := 60

var _gagal := 0
var _data: GameData


func _init() -> void:
	_data = GameData.load_from("res://data")
	_test_deterministik()
	_test_selesai_dan_batas_hp()
	_test_semua_aksi_muncul()
	_test_target_depan_dulu()
	_test_unggul_elemen()
	_test_blok_mengurangi_damage()
	print("HASIL: %s" % ("LULUS" if _gagal == 0 else "%d GAGAL" % _gagal))
	quit(1 if _gagal > 0 else 0)


func _cek(ok: bool, nama: String) -> void:
	print("%s %s" % ["ok  " if ok else "GAGAL", nama])
	if not ok:
		_gagal += 1


func _tim(ids: Array) -> Array:
	var t: Array = []
	for id: String in ids:
		t.append(_data.get_dragon(id))
	return t


func _jalankan(a: Array, b: Array, cfg: Dictionary, rng_seed: int) -> Array:
	var sim := BattleSim.new(a, b, cfg, rng_seed)
	var log: Array = []
	while not sim.is_over():
		log.append(sim.step())
	log.append({"menang": sim.winner()})
	return log


func _cfg_tanpa_acak() -> Dictionary:
	var cfg := _data.battle.duplicate(true)
	cfg["varian"] = 0.0
	cfg["hindar_dasar"] = 0.0
	cfg["hindar_per_spd"] = 0.0
	cfg["blok_dasar"] = 0.0
	cfg["blok_per_def"] = 0.0
	return cfg


func _test_deterministik() -> void:
	var a := _tim(["ice_dragon", "storm_dragon", "golden_dragon"])
	var b := _tim(["dragon", "swamp_dragon", "shadow_dragon"])
	var sama := str(_jalankan(a, b, _data.battle, 7)) == str(_jalankan(a, b, _data.battle, 7))
	var beda := str(_jalankan(a, b, _data.battle, 7)) != str(_jalankan(a, b, _data.battle, 8))
	_cek(sama, "seed sama -> hasil sama")
	_cek(beda, "seed beda -> hasil beda")


func _test_selesai_dan_batas_hp() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var selesai := true
	var hp_ok := true
	var mati_diam := true
	for s in SEED_COUNT:
		var sim := BattleSim.new(_data.random_team(rng), _data.random_team(rng), _data.battle, s)
		while not sim.is_over():
			var ev := sim.step()
			var aktor: BattleSim.Unit = sim.units[ev["uid"]]
			if not aktor.hidup():
				mati_diam = false
			for u in sim.units:
				if u.hp < 0 or u.hp > u.hp_max:
					hp_ok = false
		if sim.winner() != 0 and sim.winner() != 1:
			selesai = false
	_cek(selesai, "%d battle acak selesai dengan pemenang" % SEED_COUNT)
	_cek(hp_ok, "hp selalu 0..hp_max")
	_cek(mati_diam, "naga mati tidak bertindak")


func _test_semua_aksi_muncul() -> void:
	var a := _tim(["ice_dragon", "storm_dragon", "golden_dragon"])
	var b := _tim(["dragon", "swamp_dragon", "shadow_dragon"])
	var ada := {"serang": false, "jurus": false, "hindar": false, "blok": false, "kena": false}
	for s in SEED_COUNT:
		for ev: Dictionary in _jalankan(a, b, _data.battle, s):
			if not ev.has("hits"):
				continue
			ada[ev["jenis"]] = true
			for h: Dictionary in ev["hits"]:
				ada[h["hasil"]] = true
	_cek(not ada.values().has(false), "serang, jurus, hindar, blok, kena semuanya terjadi")


func _test_target_depan_dulu() -> void:
	var a := _tim(["ice_dragon", "storm_dragon", "golden_dragon"])
	var b := _tim(["dragon", "swamp_dragon", "shadow_dragon"])
	var sim := BattleSim.new(a, b, _data.battle, 3)
	var ok := true
	while not sim.is_over():
		var depan := [sim.alive(0), sim.alive(1)]
		var ev := sim.step()
		if ev["jenis"] != "serang":
			continue
		var aktor: BattleSim.Unit = sim.units[ev["uid"]]
		var harus: BattleSim.Unit = depan[1 - aktor.side][0]
		if ev["hits"][0]["uid"] != harus.uid:
			ok = false
	_cek(ok, "serangan biasa selalu ke naga paling depan yang hidup")


func _dmg_pertama(penyerang: String, target: String, cfg: Dictionary) -> int:
	var a := [_data.get_dragon(penyerang).duplicate()]
	var b := [_data.get_dragon(target).duplicate()]
	a[0]["spd"] = 99
	a[0]["atk"] = 40
	b[0]["def"] = 10
	b[0]["spd"] = 1
	var sim := BattleSim.new(a, b, cfg, 1)
	return sim.step()["hits"][0]["dmg"]


func _test_unggul_elemen() -> void:
	var cfg := _cfg_tanpa_acak()
	var kuat := _dmg_pertama("dragon", "ice_dragon", cfg)  # api -> es
	var netral := _dmg_pertama("dragon", "storm_dragon", cfg)  # api -> petir
	var lemah := _dmg_pertama("dragon", "steam_dragon", cfg)  # api -> air
	_cek(kuat > netral and netral > lemah, "unggul elemen: %d > %d > %d" % [kuat, netral, lemah])
	_cek(kuat == roundi(netral * float(cfg["unggul_kali"])), "pengali unggul sesuai battle.json")


func _test_blok_mengurangi_damage() -> void:
	var cfg := _cfg_tanpa_acak()
	var biasa := _dmg_pertama("dragon", "storm_dragon", cfg)
	cfg["blok_dasar"] = 1.0
	cfg["blok_maks"] = 1.0
	var diblok := _dmg_pertama("dragon", "storm_dragon", cfg)
	_cek(diblok == roundi(biasa * (1.0 - float(cfg["blok_reduksi"]))), "blok: %d -> %d" % [biasa, diblok])
