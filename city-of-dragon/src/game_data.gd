class_name GameData
extends RefCounted
## Data game dari berkas JSON di `res://data`. Semua angka battle ada di sana, bukan di kode.

## Isi `battle.json`.
var battle: Dictionary = {}
## Daftar naga dari `dragons.json` (Array of Dictionary).
var dragons: Array = []


## Muat `battle.json` dan `dragons.json` dari folder [param dir].
static func load_from(dir: String) -> GameData:
	var d := GameData.new()
	d.battle = _read(dir.path_join("battle.json"))
	d.dragons = _read(dir.path_join("dragons.json")).get("dragons", [])
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


static func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert(parsed is Dictionary, "JSON tidak valid: " + path)
	return parsed
