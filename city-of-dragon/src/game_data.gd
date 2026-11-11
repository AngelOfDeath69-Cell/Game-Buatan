class_name GameData
extends RefCounted
## Data game dari berkas JSON di `res://data`. Semua angka battle ada di sana, bukan di kode.

## Isi `battle.json`.
var battle: Dictionary = {}
## Daftar naga dari `dragons.json` (Array of Dictionary).
var dragons: Array = []
## Isi `koleksi.json`: naga awal, jenis telur, bobot tingkat.
var koleksi: Dictionary = {}


## Muat `battle.json` dan `dragons.json` dari folder [param dir].
static func load_from(dir: String) -> GameData:
	var d := GameData.new()
	d.battle = _read(dir.path_join("battle.json"))
	d.dragons = _read(dir.path_join("dragons.json")).get("dragons", [])
	d.koleksi = _read(dir.path_join("koleksi.json"))
	return d


## Cari naga berdasarkan id. Mengembalikan {} bila tidak ada.
func get_dragon(id: String) -> Dictionary:
	for d: Dictionary in dragons:
		if d["id"] == id:
			return d
	return {}


## Pilih tim acak tanpa naga kembar.
func random_team(rng: RandomNumberGenerator) -> Array:
	var pool := dragons.duplicate()
	var team: Array = []
	var n: int = battle["ukuran_tim"]
	while team.size() < n and not pool.is_empty():
		team.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return team


## Tim lawan yang setara: tiap slot bertingkat sama dengan naga pemain di slot itu.
func tim_lawan(team: Array, rng: RandomNumberGenerator) -> Array:
	var lawan: Array = []
	for d: Dictionary in team:
		var pool: Array = dragons.filter(func(x: Dictionary) -> bool:
			return x["tingkat"] == d["tingkat"] and not lawan.has(x))
		if pool.is_empty():
			pool = dragons.filter(func(x: Dictionary) -> bool: return not lawan.has(x))
		lawan.append(pool[rng.randi_range(0, pool.size() - 1)])
	return lawan


## Cari jenis telur berdasarkan id. Mengembalikan {} bila tidak ada.
func get_egg(id: String) -> Dictionary:
	for e: Dictionary in koleksi["telur"]:
		if e["id"] == id:
			return e
	return {}


## Pilih jenis telur hadiah menurut bobot di `koleksi.json`.
func pilih_telur_hadiah(rng: RandomNumberGenerator) -> String:
	var telur: Array = koleksi["telur"]
	var bobot: Array = telur.map(func(e: Dictionary) -> float: return e["bobot"])
	return telur[pilih_berbobot(bobot, rng)]["id"]


## Indeks acak menurut bobot. [param bobot] tidak boleh kosong.
static func pilih_berbobot(bobot: Array, rng: RandomNumberGenerator) -> int:
	var total := 0.0
	for b: float in bobot:
		total += b
	var r := rng.randf() * total
	for i in bobot.size():
		r -= float(bobot[i])
		if r < 0.0:
			return i
	return bobot.size() - 1


static func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert(parsed is Dictionary, "JSON tidak valid: " + path)
	return parsed
