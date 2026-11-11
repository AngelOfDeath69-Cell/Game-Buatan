class_name PlayerState
extends RefCounted
## Milik pemain: naga yang dipunyai dan telur yang belum menetas.

## Id naga yang dimiliki.
var owned: Array[String] = []
## Id jenis telur yang belum menetas.
var eggs: Array[String] = []


## Pemain baru: naga awal dan telur awal dari `koleksi.json`.
static func baru(data: GameData) -> PlayerState:
	return from_dict({"owned": data.koleksi["naga_awal"], "eggs": data.koleksi["telur_awal"]}, data)


## Bangun dari isi berkas simpan. Id yang tidak dikenal dibuang.
static func from_dict(d: Dictionary, data: GameData) -> PlayerState:
	var s := PlayerState.new()
	for id: Variant in d.get("owned", []):
		if id is String and not data.get_dragon(id).is_empty() and not s.owned.has(id):
			s.owned.append(id)
	for id: Variant in d.get("eggs", []):
		if id is String and not data.get_egg(id).is_empty():
			s.eggs.append(id)
	return s


func to_dict() -> Dictionary:
	return {"owned": owned, "eggs": eggs}


## Muat dari berkas; pemain baru bila berkas tidak ada, rusak, atau tanpa naga.
static func muat(path: String, data: GameData) -> PlayerState:
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			var s := from_dict(parsed, data)
			if not s.owned.is_empty():
				return s
	return baru(data)


func simpan(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(to_dict()))


## Data naga yang dimiliki, urut seperti di `dragons.json`.
func naga_dimiliki(data: GameData) -> Array:
	return data.dragons.filter(func(d: Dictionary) -> bool: return owned.has(d["id"]))


## False bila semua naga sudah dimiliki (telur tidak bisa menetas lagi).
func bisa_menetas(data: GameData) -> bool:
	return owned.size() < data.dragons.size()


## Tetaskan telur ke-[param index]. Selalu menghasilkan naga yang belum dimiliki:
## dari elemen telur itu bila masih ada, kalau tidak dari elemen mana pun.
## Mengembalikan data naga baru, atau {} bila tidak bisa menetas.
func tetas(index: int, data: GameData, rng: RandomNumberGenerator) -> Dictionary:
	if index < 0 or index >= eggs.size() or not bisa_menetas(data):
		return {}
	var telur := data.get_egg(eggs[index])
	var elemen: Array = telur["elemen"]
	var belum: Array = data.dragons.filter(func(d: Dictionary) -> bool: return not owned.has(d["id"]))
	var calon: Array = belum.filter(func(d: Dictionary) -> bool: return elemen.has(d["elemen"]))
	if calon.is_empty():
		calon = belum
	var bobot_tingkat: Dictionary = data.koleksi["bobot_tingkat"]
	var bobot: Array = calon.map(func(d: Dictionary) -> float:
		return bobot_tingkat[str(int(d["tingkat"]))])
	var naga: Dictionary = calon[GameData.pilih_berbobot(bobot, rng)]
	eggs.remove_at(index)
	owned.append(naga["id"])
	return naga
