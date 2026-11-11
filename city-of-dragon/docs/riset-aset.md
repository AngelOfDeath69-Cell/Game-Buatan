# Riset Aset 2D — City of Dragon: Epic Battle
Tanggal: 2026-11-11 · Status: riset selesai, 18 pack CC0 terpasang · Lisensi wajib dicek ulang di halaman sumber sebelum dipakai.

## 1. Sumber naga gratis
| Pack | Isi | Gaya | Lisensi | Cocok untuk |
|---|---|---|---|---|
| [Free Pixel Art Dragons — Magicae](https://magicae-games.itch.io/free-pixel-art-dragons) | 4 elemen (api/air/tanah/udara), 4 arah, 11 animasi | Pixel kecil (skala tile 32px) | Komersial boleh, dilarang jual ulang | Naga jalan di kota |
| [Dragon Fully Animated — Cethiel](https://opengameart.org/content/dragon-fully-animated) | 1 naga: idle/attack/hurt/death/walk | belum dicek (halaman 403) | CC0 | Battle |
| [2D Dragon Spritesheet — D. Quevedo](https://opengameart.org/content/2d-dragon-spritesheet) | 1 naga, PNG+PSD | belum dicek | CC0 | Battle |
| [Free Dragon Pack #1 — Art of Nemo](https://theartofnemo.itch.io/free-dragon-pack-1) | 7 naga, statis | Battler lukis (RPG Maker) | Wajib kredit, no NFT; komersial tidak tertulis | Kartu koleksi / battle |
| [Dragon Evolutions — Art of Nemo](https://theartofnemo.itch.io/free-rpg-monsters-dragon-evolutions) | 3 naga × bayi/remaja/dewasa, statis | Battler lukis | Wajib kredit; komersial OK menurut komentar pembuat | Sistem evolusi |
| [Knight & Dragon — liteboot](https://liteboot.itch.io/knight-dragon-free-sprite) | 1 naga | Vektor | CC0 | Musuh/boss |
| [Dragon Sprites — Chibizilla](https://opengameart.org/content/dragon-sprites) | set naga | belum dicek | CC-BY 4.0 (kredit) | Tambahan |

Murah, bukan gratis: [Dan's Monsters Pack01](https://danieruart.itch.io/dans-monsters-pack01) — $1.99, 30 monster (15 bayi + 15 dewasa), 64px, gaya kolektor, ada Fire Dragon.
Hindari dulu: [Evolving Dragons](https://michael-jay-rov.itch.io/evolving-dragons) — CC BY-SA (share-alike) + dibuat dengan bantuan AI.

## 2. Sumber non-naga (UI, kota, ikon)
- [Kenney](https://kenney.nl/assets) — CC0: UI, ikon, tile kota/bangunan.
- [OpenGameArt](https://opengameart.org) — filter lisensi CC0.
- itch.io: `itch.io/game-assets/free/tag-dragons`.

## 3. Kenyataan
- Gratis total ≈ 15–20 naga, **gaya campur** (pixel kecil vs lukisan besar). Game kolektor butuh puluhan naga satu gaya.
- Animasi battle lengkap hanya ada di 1–2 pack.
- Pilih SATU gaya dulu, baru unduh — mencampur gaya = game terlihat tambal-sulam.

## 4. Repo `awesome-gamedev-agent-skills` — bermanfaat? Ya, sebagian
| Skill | Guna |
|---|---|
| `disciplines/create-game-assets` | Brief art, manifest aset + lisensi/asal, skrip cek PNG (`asset_report.py`, `build_preview_sheet.py`). Tidak berisi aset atau daftar sumber. |
| `godot/*` (16), `unity/*`, `web-engines/phaser-*` | Panduan engine |
| `genres/rpg`, `genres/card-game` | Terdekat ke battle/koleksi (tidak ada genre creature-collector) |
| `disciplines/game-ui-ux`, `save-systems` | UI koleksi, simpan data |

## 5. Keputusan (final 2026-11-11)
Gaya: **pixel art** · Strategi: **hybrid** (gratis dulu, tambah belakangan) · Engine: **Godot 4**
Platform: **Android + PC, landscape** · Battle: **samping, tim vs tim, otomatis** (pemain atur naga + formasi)
Aset awal: **3 pack gratis** (Magicae, Tiny Dragon, Cethiel) — diunduh pemilik proyek.

## 6. Shortlist pixel
| Pack | Harga | Isi | Lisensi |
|---|---|---|---|
| [Free Pixel Art Dragons — Magicae](https://magicae-games.itch.io/free-pixel-art-dragons) | Gratis | 4 elemen, 4 arah, 11 animasi | Komersial OK, no jual ulang |
| [Tiny Dragon Sprite Pack](https://browser-games-plus.itch.io/tiny-dragon-sprite-pack) | Gratis | 8 naga elemen 64×64, 1 animasi (bounce 6 frame) | Komersial OK, no redistribusi; dibuat dengan bantuan AI |
| [Dragon Fully Animated — Cethiel](https://opengameart.org/content/dragon-fully-animated) | Gratis | idle/attack/hurt/death/walk | CC0 (gaya belum dicek) |
| [Pixel Creatures: Night Dragon](https://kittensoverboard.itch.io/pixel-creatures-night-dragon) | $1 | 12 animasi (terbang, fireball, slash, mati) | Komersial OK, no redistribusi |
| [Dan's Monsters Pack01](https://danieruart.itch.io/dans-monsters-pack01) | $1.99 | 30 monster bayi+dewasa 64px, statis | CC-BY 4.0, no redistribusi |
| [Faerie Dragon — Elthen](https://elthen.itch.io/2d-pixel-art-faerie-dragon-sprites) | $3 | 64×64: idle, gigit, sembur, hurt, mati | Komersial OK |
| [Dragon — Elthen](https://elthen.itch.io/2d-pixel-art-dragon-sprites) | $8 (bundle 6 naga $25) | 10 animasi | Komersial OK |

Gratis saja = 13 naga pixel (4 + 8 + 1).

## 6b. Terpasang (2026-11-11) — 18 pack CC0 dari OpenGameArt
Diunduh langsung dan sudah ada di `assets/`: 47 naga + 6 makhluk 32×32 satu gaya, 4 boss, naga kota 16×16, 10 telur, 3 pack UI, 2 tileset kota, 16 latar, 2 pack efek + 238 efek, 911 ikon. Rincian: `assets/asset-manifest.json`, `assets/CREDITS.md`, pratinjau di `docs/pratinjau/`.
- Pack itch.io (Magicae, Tiny Dragon) tidak terpasang: itch.io tidak bisa diunduh otomatis. Opsional, unduh manual.
- Cethiel ditolak: ternyata render 3D, bukan pixel art.
- Kekurangan utama: naga masih **statis 1 frame** (animasi dibuat di engine dulu), audio belum ada.

## 7. Kendala
- Unduh otomatis tidak bisa: itch.io perlu klik tombol, OpenGameArt menolak akses otomatis. **Kamu unduh zip → unggah → aku rapikan, cek, potong frame, impor ke Godot.**
- Pack "no redistribusi" tidak boleh ada di repo publik → repo game harus privat, atau folder aset di-`.gitignore`.

## 8. Catatan
- Nama mirip *Dragon City* (Socialpoint): desain, nama naga, dan tampilan harus orisinal.
