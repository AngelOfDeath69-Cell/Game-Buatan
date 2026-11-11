# Hatch & Fuse: Dragon Arena
Kumpul telur · menetas · fusion · auto-battle tim vs tim. Godot 4.7, pixel art, Android + PC landscape (640×360).

## Status: prototipe telur + fusion + auto-battle
0. Layar Home: menu Battle / Telur / Fusion; tombol pengaturan (kunci pas) di pojok kanan atas.
1. Mulai dengan 3 naga + 1 telur.
2. Pilih 3 naga (depan/tengah/belakang) → battle 3 lawan 3 berjalan sendiri: serang, jurus, hindar, blok. Lawan setingkat dan sebintang.
3. Menang → dapat telur → telur menetas jadi naga (48 jenis, boleh kembar).
4. Fusion: 2 naga sama + bintang sama → 1 naga bintang lebih tinggi (maks 5; tiap bintang +25% HP/ATK/DEF). Tidak ada level/EXP.
5. Layar Pengaturan terpisah: bahasa (Inggris / Indonesia) dan kecepatan battle (x1 / x2).
6. Naga, telur, dan pengaturan tersimpan otomatis di perangkat.

Screenshot: `docs/pratinjau/game-*.png`.

## Menjalankan
| Tujuan | Perintah (dari folder ini) |
|---|---|
| Buka di editor | Godot 4.7 → Import → pilih `project.godot` → F5 |
| Main langsung | `godot --path .` |
| Tes logika battle | `godot --headless -s res://tests/test_battle_sim.gd` |
| Tes telur + fusion + bahasa | `godot --headless -s res://tests/test_player_state.gd` |
| Ambil screenshot otomatis | `xvfb-run -a godot --fixed-fps 60 -s res://tools/capture.gd -- FOLDER` |
| Buat APK Android (debug) | `godot --headless --export-debug "Android" build/hatch-and-fuse-debug.apk` |

APK butuh: template ekspor Godot 4.7.2, Android SDK (platform-tools + build-tools), Java 17+. Hasilnya di `build/` (tidak ikut di-commit). Paket: `com.gamebuatan.hatchandfuse`, arm64 saja.

## Struktur
| Lokasi | Isi |
|---|---|
| `data/dragons.json` | 48 naga: nama (ID + EN), elemen, tingkat, HP/ATK/DEF/SPD |
| `data/battle.json` | Semua angka battle: peluang hindar/blok, unggul elemen, jurus, efek, arena |
| `data/koleksi.json` | Naga awal, 10 jenis telur (elemen + peluang), peluang tingkat, aturan fusion |
| `data/teks.json` | Semua teks antarmuka dalam 2 bahasa |
| `src/player_state.gd` | Naga pemain, telur menetas, fusion, simpan/muat |
| `src/battle/battle_sim.gd` | Logika battle (tanpa tampilan, deterministik per seed) |
| `src/battle/battle_view.gd`, `unit_view.gd` | Arena + animasi tween |
| `src/ui/ui_theme.gd` | Kit UI dari gambar Dragon Regalia: tombol, panel, pita judul, tombol bulat, bintang, bar |
| `src/ui/home_screen.gd`, `settings_screen.gd` | Layar utama dan layar pengaturan |
| `src/ui/formation_screen.gd` | Layar pilih formasi |
| `src/ui/egg_screen.gd`, `fusion_screen.gd` | Layar telur dan layar fusion + animasinya |
| `tests/` | 36 cek logika (battle 10, telur/fusion/bahasa 26) |
| `docs/art-direction-brief.md` | Aturan gaya, ukuran sprite, folder |
| `docs/riset-aset.md` | Sumber aset + lisensi |
| `assets/asset-manifest.json`, `assets/CREDITS.md` | Pack terpasang, lisensi, kredit |

## Aset terpasang (semua CC0)
| Folder | Isi |
|---|---|
| `assets/dragons/` | 48 naga 32×32, 4 boss, naga kota 16×16 |
| `assets/makhluk/` | 6 makhluk non-naga 32×32 |
| `assets/eggs/` | 10 telur + animasi menetas |
| `assets/ui/`, `assets/fonts/` | 3 pack UI, 2 font pixel |
| `assets/kota/` | Tileset pulau melayang + 1700 tile bangunan/alam |
| `assets/bg/` | 14 arena battle + 2 latar besar |
| `assets/vfx/` | Efek jurus |
| `assets/icons/` | 911 ikon jurus/item |

## Belum ada
Tahap petualangan + boss, mata uang/toko, audio, sprite naga beranimasi (gerak sekarang dibuat engine), APK rilis untuk Play Store (butuh keystore milik sendiri).

## Catatan orisinalitas
Terinspirasi genre kumpul telur → menetas → fusion → battle. Nama game, nama naga, gambar (CC0), dan semua data dibuat sendiri; tidak meniru game lain.
