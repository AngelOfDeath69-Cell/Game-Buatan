# Catatan Sesi — Hatch & Fuse: Dragon Arena
Rangkuman seluruh pembahasan sesi 2026-11-11 s.d. 2026-11-12, untuk dibaca sesi lain yang tidak bisa membuka percakapan aslinya.
Branch: `ccr-a6e16ee1-c60e0h` · PR: #1 di `AngelOfDeath69-Cell/Game-Buatan` (belum digabung saat catatan ini ditulis).

## 1. Tujuan pemilik
- Membuat game **seperti** "City of Dragon(s): Epic Battle" (game orang lain di Play Store): kumpul telur → menetas → fusion → battle. Game acuan itu **tidak** punya fitur bangun kota.
- Nama itu **bukan** nama game kita. Hanya jenis mekanik genrenya yang dipakai; nama, naga, gambar, dan data harus milik sendiri.
- Masalah utama pemilik: aset. Wajib **gambar sungguhan**, bukan aset yang digambar lewat kode.

## 2. Preferensi kerja pemilik (wajib diikuti)
- Semua usulan/opsi disajikan sebagai **pilihan yang bisa diklik**, maksimal 3 pertanyaan per kali, dengan rekomendasi; lalu tunggu jawaban.
- Kerja lewat berkas, simpan bertahap, jangan ulang yang sudah final.
- Rapi, simpel, terstruktur, **hemat token**, sedikit bicara.
- Pemilik tidak mau repot mengunduh sendiri: aset diunduhkan dan dipasangkan.

## 3. Keputusan final
| Hal | Keputusan |
|---|---|
| Judul | **Hatch & Fuse: Dragon Arena** (judul bahasa Inggris; ketersediaan di Play Store belum dicek) |
| Folder / paket | `hatch-and-fuse/` · `com.gamebuatan.hatchandfuse` |
| Repo | `Game-Buatan`: kumpulan banyak game; tiap game satu folder |
| Gaya gambar | Pixel art, satu gaya (tile naga Dungeon Crawl Stone Soup 32×32) |
| Strategi aset | Hybrid: gratis (CC0) dulu, tambah belakangan bila perlu |
| Engine | Godot 4.7 (dipakai 4.7.2), GDScript, renderer Compatibility |
| Platform | Android + PC, landscape, viewport 640×360 skala bulat |
| Battle | Tampak samping, tim vs tim 3 lawan 3, **otomatis** (serang, jurus, hindar, blok); pemain hanya memilih naga + formasi |
| Animasi naga | Sprite 1 frame; gerak dibuat tween di engine |
| Elemen | 11 elemen + "multi" (usulan, bisa diubah di data) |
| Pertumbuhan naga | **Fusion saja**, tanpa level/EXP: 2 naga sama + bintang sama → bintang +1 (maks 5, +25% HP/ATK/DEF per bintang) |
| Telur | Menang battle → 1 telur; menetas bisa memberi naga kembar; kalah tidak dapat apa-apa |
| Bahasa | Inggris + Indonesia di dalam game |
| Pengaturan | Layar terpisah, tombol di pojok kanan atas Home: bahasa + kecepatan battle x1/x2 |
| UI | Seluruhnya dari gambar pack "Dragon Regalia GUI" (CC0) |

## 4. Urutan pekerjaan
1. Riset sumber aset 2D gratis; menilai repo `awesome-gamedev-agent-skills` (berguna sebagian: skill `create-game-assets` untuk brief, manifest, cek PNG; tidak berisi aset).
2. Brief art + manifest aset.
3. Unduh 49 pack CC0 dari OpenGameArt; pilih dan pasang yang cocok ke `assets/`.
4. Prototipe Godot: formasi + auto-battle.
5. Koleksi, telur menetas, simpan data.
6. Ekspor Android (APK debug). Pemilik mencoba APK pertama: **jalan normal**.
7. Ganti nama (dari judul kerja yang ternyata nama game lain), fusion, dua bahasa.
8. Rombak UI: Home, Pengaturan, bingkai bertema naga, ikon bintang.
9. Semua unduhan asli dimasukkan ke `aset-mentah/`.

## 5. Keadaan sekarang
- Alur yang jalan: Home → Pengaturan / Telur / Fusion / Battle (formasi → battle → menang dapat telur) → Home. Tersimpan di `user://save.json`.
- Tes: `tests/test_battle_sim.gd` 10 cek lulus, `tests/test_player_state.gd` 26 cek lulus.
- Bukti jalan: `docs/pratinjau/game-*.png` (diambil otomatis oleh `tools/capture.gd`).
- APK v0.2.0 (UI baru) sudah dikirim ke pemilik lewat percakapan, **belum dicoba di HP**. APK tidak disimpan di repo.
- Cara menjalankan, struktur berkas, daftar aset: `../README.md`.

## 6. Aset
- Terpasang di game: `assets/` (lisensi di `assets/asset-manifest.json`, kredit di `assets/CREDITS.md`).
- Semua unduhan asli: `../../aset-mentah/` (49 pack, semua CC0, daftar di `aset-mentah/README.md`). Pack naga beranimasi 133 MB dipecah 2 bagian karena batas GitHub 100 MB.
- Tidak terpasang: pack itch.io (Magicae, Tiny Dragon) — itch.io tidak bisa diunduh otomatis. Naga beranimasi Cethiel ditolak untuk game karena render 3D, bukan pixel art.
- Unduhan otomatis hanya berhasil dari OpenGameArt (unduh biasa, tanpa mengakali proteksi situs). kenney.nl menolak.

## 7. Belum dikerjakan
- Tahap petualangan + boss (disarankan berikutnya), layar koleksi naga, audio, mata uang/toko.
- Sprite naga beranimasi asli.
- APK rilis untuk Play Store (butuh keystore milik sendiri).
- Nilai stat, tabel elemen, peluang telur, bonus bintang masih usulan awal, belum diseimbangkan.
- Pemilik belum memberi pendapat soal UI baru (pilihan yang ditawarkan: sudah bagus / warna / ukuran teks-tombol / tata letak).

## 8. Catatan teknis untuk sesi berikutnya
- Membangun APK butuh: Godot 4.7.2 + template ekspor, Android SDK (platform-tools, build-tools), Java 17+. Di sesi cloud baru semuanya harus dipasang ulang.
- Jangan menulis README lewat heredoc shell tanpa tanda kutip: backtick di dalamnya ikut dijalankan.
- Clone dangkal hanya melacak `main`; tambahkan refspec branch kerja supaya status dorong terbaca benar.
- Teks antarmuka: `data/teks.json` (kunci harus sama di `en` dan `id`; ada tesnya).
