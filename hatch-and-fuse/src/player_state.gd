class_name PlayerState
extends RefCounted
## Milik pemain: naga (boleh kembar, tiap naga punya bintang), telur, dan bahasa.

const VERSI := 2

## Naga yang dimiliki. Tiap entri: {"id": String, "b": int} (b = bintang, mulai 1).
var naga: Array[Dictionary] = []
## Id jenis telur yang belum menetas.
var eggs: Array[String] = []
## Kode bahasa antarmuka: "en" atau "id".
var bahasa := "en"


## Pemain baru: naga awal dan telur awal dari `koleksi.json`.
static func baru(data: GameData) -> PlayerState:
	return from_dict({"owned": data.koleksi["naga_awal"], "eggs": data.koleksi["telur_awal"]}, data)


## Bangun dari isi berkas simpan. Entri yang tidak dikenal dibuang.
## Menerima format lama (v1: "owned" = daftar id) dan baru (v2: "naga").
static func from_dict(d: Dictionary, data: GameData) -> PlayerState:
	var s := PlayerState.new()
	var maks := int(data.koleksi["maks_bintang"])
	for id: Variant in d.get("owned", []):
		if id is String and not data.get_dragon(id).is_empty():
			s.naga.append({"id": id, "b": 1})
	for n: Variant in d.get("naga", []):
		if n is Dictionary and n.get("id") is String and not data.get_dragon(n["id"]).is_empty():
			s.naga.append({"id": n["id"], "b": clampi(int(n.get("b", 1)), 1, maks)})
	for id: Variant in d.get("eggs", []):
		if id is String and not data.get_egg(id).is_empty():
			s.eggs.append(id)
	if d.get("bahasa") in GameData.BAHASA:
		s.bahasa = d["bahasa"]
	return s


func to_dict() -> Dictionary:
	return {"v": VERSI, "naga": naga, "eggs": eggs, "bahasa": bahasa}


## Muat dari berkas; pemain baru bila berkas tidak ada, rusak, atau tanpa naga.
static func muat(path: String, data: GameData) -> PlayerState:
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			var s := from_dict(parsed, data)
			if not s.naga.is_empty():
				return s
	return baru(data)


func simpan(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(to_dict()))


## Banyaknya jenis naga berbeda yang dimiliki.
func jumlah_jenis() -> int:
	var jenis := {}
	for n in naga:
		jenis[n["id"]] = true
	return jenis.size()


## Tetaskan telur ke-[param index]: naga acak dari elemen telur itu (boleh kembar),
## peluang menurut tingkat. Mengembalikan entri naga baru {"id", "b"}, atau {} bila
## indeks salah.
func tetas(index: int, data: GameData, rng: RandomNumberGenerator) -> Dictionary:
	if index < 0 or index >= eggs.size():
		return {}
	var elemen: Array = data.get_egg(eggs[index])["elemen"]
	var calon: Array = data.dragons.filter(func(d: Dictionary) -> bool: return elemen.has(d["elemen"]))
	if calon.is_empty():
		calon = data.dragons
	var bobot_tingkat: Dictionary = data.koleksi["bobot_tingkat"]
	var bobot: Array = calon.map(func(d: Dictionary) -> float:
		return bobot_tingkat[str(int(d["tingkat"]))])
	var baru_ := {"id": calon[GameData.pilih_berbobot(bobot, rng)]["id"], "b": 1}
	eggs.remove_at(index)
	naga.append(baru_)
	return baru_


## Kelompok yang bisa digabung: naga sama, bintang sama, minimal 2 ekor, belum
## bintang maksimal. Tiap entri: {"id", "b", "jumlah"}.
func kelompok_fusion(data: GameData) -> Array:
	var maks := int(data.koleksi["maks_bintang"])
	var hitung := {}
	var urut: Array = []
	for n in naga:
		var kunci := "%s:%d" % [n["id"], n["b"]]
		if not hitung.has(kunci):
			hitung[kunci] = {"id": n["id"], "b": n["b"], "jumlah": 0}
			urut.append(kunci)
		hitung[kunci]["jumlah"] += 1
	var out: Array = []
	for kunci: String in urut:
		if hitung[kunci]["jumlah"] >= 2 and hitung[kunci]["b"] < maks:
			out.append(hitung[kunci])
	return out


## Fusion: dua naga [param id] berbintang [param b] menjadi satu naga berbintang b+1.
## Mengembalikan entri naga hasil, atau {} bila tidak memenuhi syarat.
func fusion(id: String, b: int, data: GameData) -> Dictionary:
	if b >= int(data.koleksi["maks_bintang"]):
		return {}
	var idx: Array[int] = []
	for i in naga.size():
		if naga[i]["id"] == id and naga[i]["b"] == b and idx.size() < 2:
			idx.append(i)
	if idx.size() < 2:
		return {}
	naga.remove_at(idx[1])
	naga.remove_at(idx[0])
	var hasil := {"id": id, "b": b + 1}
	naga.append(hasil)
	return hasil
