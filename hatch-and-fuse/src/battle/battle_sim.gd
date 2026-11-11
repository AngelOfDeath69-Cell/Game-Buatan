class_name BattleSim
extends RefCounted
## Simulasi auto-battle tim vs tim tanpa tampilan.
##
## Naga bertindak sendiri: serang, jurus (saat energi penuh), hindar, dan blok.
## Pemain hanya menentukan naga dan urutan formasi (slot 0 = depan).
## Hasil selalu sama untuk seed yang sama.

const SERI := 2

## Satu naga di dalam battle.
class Unit:
	extends RefCounted
	var uid: int
	var side: int  ## 0 = tim pemain (kiri), 1 = lawan (kanan)
	var slot: int  ## 0 depan, 1 tengah, 2 belakang
	var id: String
	var nama: String
	var elemen: String
	var sprite: String
	var hp: int
	var hp_max: int
	var atk: int
	var def: int
	var spd: int
	var gauge: float = 0.0
	var energi: int = 0

	func hidup() -> bool:
		return hp > 0

## Semua unit, tim kiri dulu lalu tim kanan.
var units: Array[Unit] = []

var _cfg: Dictionary
var _rng := RandomNumberGenerator.new()
var _winner := -1
var _aksi := 0


## [param team_a] dan [param team_b]: Array data naga (lihat `dragons.json`), urut dari depan.
func _init(team_a: Array, team_b: Array, cfg: Dictionary, rng_seed: int) -> void:
	_cfg = cfg
	_rng.seed = rng_seed
	for side in 2:
		var team: Array = team_a if side == 0 else team_b
		for slot in team.size():
			var d: Dictionary = team[slot]
			var u := Unit.new()
			u.uid = units.size()
			u.side = side
			u.slot = slot
			u.id = d["id"]
			u.nama = d["nama"]
			u.elemen = d["elemen"]
			u.sprite = d["sprite"]
			u.hp = int(d["hp"])
			u.hp_max = u.hp
			u.atk = int(d["atk"])
			u.def = int(d["def"])
			u.spd = maxi(1, int(d["spd"]))
			units.append(u)


## True bila battle sudah selesai.
func is_over() -> bool:
	return _winner != -1


## -1 belum selesai, 0 tim kiri menang, 1 tim kanan menang, [constant SERI] seri.
func winner() -> int:
	return _winner


## Jalankan satu aksi. Mengembalikan event aksi, atau {} bila battle sudah selesai.
## Event: {uid, jenis: "serang"|"jurus", jurus (kunci di battle.json), vfx, warna, hits: [{uid, hasil:
## "kena"|"blok"|"hindar", dmg, hp, efektif: -1|0|1, mati}]}.
func step() -> Dictionary:
	if is_over():
		return {}
	var ev := _act(_next_actor())
	_aksi += 1
	_check_end()
	return ev


## Unit hidup di satu sisi, urut dari depan.
func alive(side: int) -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if u.side == side and u.hidup():
			out.append(u)
	return out


func _next_actor() -> Unit:
	var penuh: float = _cfg["gauge_penuh"]
	while true:
		var best: Unit = null
		for u in units:
			if u.hidup() and u.gauge >= penuh and (best == null or u.gauge > best.gauge):
				best = u
		if best != null:
			best.gauge -= penuh
			return best
		for u in units:
			if u.hidup():
				u.gauge += u.spd
	return null


func _act(actor: Unit) -> Dictionary:
	var energi_penuh: int = _cfg["energi_penuh"]
	var jurus_semua: Dictionary = _cfg["jurus"]
	var kunci: String = actor.elemen if jurus_semua.has(actor.elemen) else "default"
	var jurus: Dictionary = jurus_semua[kunci]
	var musuh := alive(1 - actor.side)
	var pakai_jurus := actor.energi >= energi_penuh
	var kali := 1.0
	var target: Array[Unit] = [musuh[0]]
	if pakai_jurus:
		actor.energi = 0
		kali = jurus["kali"]
		if jurus["target"] == "semua":
			target = musuh
	else:
		actor.energi = mini(actor.energi + int(_cfg["energi_serang"]), energi_penuh)
	var hits: Array = []
	for t in target:
		hits.append(_resolve(actor, t, kali))
	return {
		"uid": actor.uid,
		"jenis": "jurus" if pakai_jurus else "serang",
		"jurus": kunci if pakai_jurus else "",
		"vfx": jurus["vfx"] if pakai_jurus else "",
		"warna": jurus["warna"] if pakai_jurus else "ffffff",
		"hits": hits,
	}


func _resolve(a: Unit, t: Unit, kali: float) -> Dictionary:
	var hit := {"uid": t.uid, "hasil": "kena", "dmg": 0, "hp": t.hp, "efektif": 0, "mati": false}
	var p_hindar := clampf(_cfg["hindar_dasar"] + _cfg["hindar_per_spd"] * t.spd, 0.0, _cfg["hindar_maks"])
	if _rng.randf() < p_hindar:
		hit["hasil"] = "hindar"
		return hit
	var e := _elem_mult(a.elemen, t.elemen)
	var varian: float = _cfg["varian"]
	var raw: float = (a.atk * kali - t.def * float(_cfg["def_faktor"])) * e
	raw *= _rng.randf_range(1.0 - varian, 1.0 + varian)
	var p_blok := clampf(_cfg["blok_dasar"] + _cfg["blok_per_def"] * t.def, 0.0, _cfg["blok_maks"])
	if _rng.randf() < p_blok:
		hit["hasil"] = "blok"
		raw *= 1.0 - float(_cfg["blok_reduksi"])
	var dmg := maxi(1, roundi(raw))
	t.hp = maxi(0, t.hp - dmg)
	t.energi = mini(t.energi + int(_cfg["energi_kena"]), int(_cfg["energi_penuh"]))
	hit["dmg"] = dmg
	hit["hp"] = t.hp
	hit["efektif"] = 1 if e > 1.0 else (-1 if e < 1.0 else 0)
	hit["mati"] = not t.hidup()
	return hit


func _elem_mult(penyerang: String, target: String) -> float:
	var unggul: Dictionary = _cfg["unggul"]
	if target in unggul.get(penyerang, []):
		return _cfg["unggul_kali"]
	if penyerang in unggul.get(target, []):
		return _cfg["lemah_kali"]
	return 1.0


func _check_end() -> void:
	var kiri := not alive(0).is_empty()
	var kanan := not alive(1).is_empty()
	if kiri and kanan:
		if _aksi >= int(_cfg["maks_aksi"]):
			_winner = SERI
	elif kiri:
		_winner = 0
	elif kanan:
		_winner = 1
	else:
		_winner = SERI
