# City of Dragon: Epic Battle
Kolektor naga · auto-battle tim vs tim · bangun kota. Godot 4.7, pixel art, Android + PC landscape (640×360).

## Status: prototipe auto-battle
Pilih 3 naga (depan/tengah/belakang) → battle 3 lawan 3 berjalan sendiri: serang, jurus, hindar, blok. Lawan acak.
Screenshot: `docs/pratinjau/game-*.png`.

## Menjalankan
| Tujuan | Perintah (dari folder ini) |
|---|---|
| Buka di editor | Godot 4.7 → Import → pilih `project.godot` → F5 |
| Main langsung | `godot --path .` |
| Tes logika battle | `godot --headless -s res://tests/test_battle_sim.gd` |
| Ambil screenshot otomatis | `xvfb-run -a godot --fixed-fps 60 -s res://tools/capture.gd -- FOLDER` |

## Struktur
| Lokasi | Isi |
|---|---|
| `data/dragons.json` | 48 naga: nama, elemen, tingkat, HP/ATK/DEF/SPD |
| `data/battle.json` | Semua angka battle: peluang hindar/blok, unggul elemen, jurus, efek, arena |
| `src/battle/battle_sim.gd` | Logika battle (tanpa tampilan, deterministik per seed) |
| `src/battle/battle_view.gd`, `unit_view.gd` | Arena + animasi tween |
| `src/ui/formation_screen.gd`, `ui_theme.gd` | Layar formasi + tema UI |
| `tests/test_battle_sim.gd` | 10 tes logika |
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
Koleksi/gacha/telur menetas, evolusi, kota, simpan data, audio, sprite naga beranimasi (gerak sekarang dibuat engine), ekspor Android.
