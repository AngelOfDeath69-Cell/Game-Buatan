class_name GameData
extends RefCounted
## Data game dari berkas JSON di `res://data`. Semua angka dan teks ada di sana, bukan di kode.

const BAHASA := ["en", "id"]

## Isi `battle.json`.
var battle: Dictionary = {}
## Daftar naga dari `dragons.json` (Array of Dictionary).
var dragons: Array = []
## Isi `koleksi.json`: naga awal, jenis telur, bobot tingkat, aturan fusion.
var koleksi: Dictionary = {}
## Isi `teks.json`: teks antarmuka per bahasa.
var teks: Dictionary = {}


## Muat semua berkas data dari folder [param dir].
static func load_from(dir: String) -> GameData:
	var d := GameData.new()
	d.battle = _read(dir.path_join("battle.json"))
	d.dragons = _read(dir.path_join("dragons.json")).get("dragons", [])
	d.koleksi = _read(dir.path_join("koleksi.json"))
	d.teks = _read(dir.path_join("teks.json"))
	return d


## Daftarkan teks antarmuka ke TranslationServer supaya `tr("KUNCI")` bekerja.
func pasang_bahasa() -> void:
	for kode: String in BAHASA:
		var t := Translation.new()
		t.locale = kode
		var isi: Dictionary = teks[kode]
		for kunci: String in isi:
			t.add_message(kunci, isi[kunci])
		TranslationServer.add_translation(t)


## Nama tampil sebuah entri data (naga, telur, jurus) menurut bahasa aktif.
static func nama(d: Dictionary) -> String:
	if TranslationServer.get_locale().begins_with("id"):
		return d["nama"]
	return d.get("nama_en", d["nama"])


## Nama elemen menurut bahasa aktif.
static func nama_elemen(elemen: String) -> String:
	return TranslationServer.translate("ELEMEN_" + elemen)


## Cari naga berdasarkan id. Mengembalikan {} bila tidak ada.
func get_dragon(id: String) -> Dictionary:
	for d: Dictionary in dragons:
		if d["id"] == id:
			return d
	return {}


## Data battle untuk satu naga milik pemain. [param inst]: {"id", "b"} (b = bintang).
## HP/ATK/DEF naik `bonus_bintang` per bintang; "nama" sudah dalam bahasa aktif.
func stat_naga(inst: Dictionary) -> Dictionary:
	var d := get_dragon(inst["id"]).duplicate()
	var b := int(inst["b"])
	var kali := 1.0 + float(koleksi["bonus_bintang"]) * (b - 1)
	for k: String in ["hp", "atk", "def"]:
		d[k] = roundi(float(d[k]) * kali)
	d["bintang"] = b
	d["nama"] = nama(d)
	return d


## Pilih tim acak tanpa naga kembar (bintang 1).
func random_team(rng: RandomNumberGenerator) -> Array:
	var pool := dragons.duplicate()
	var team: Array = []
	var n: int = battle["ukuran_tim"]
	while team.size() < n and not pool.is_empty():
		team.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return team


## Tim lawan yang setara: tiap slot bertingkat dan berbintang sama dengan naga
## pemain di slot itu. [param team]: hasil [method stat_naga].
func tim_lawan(team: Array, rng: RandomNumberGenerator) -> Array:
	var dipakai: Array = []
	var lawan: Array = []
	for d: Dictionary in team:
		var pool: Array = dragons.filter(func(x: Dictionary) -> bool:
			return x["tingkat"] == d["tingkat"] and not dipakai.has(x["id"]))
		if pool.is_empty():
			pool = dragons.filter(func(x: Dictionary) -> bool: return not dipakai.has(x["id"]))
		var pilihan: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
		dipakai.append(pilihan["id"])
		lawan.append(stat_naga({"id": pilihan["id"], "b": d["bintang"]}))
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
