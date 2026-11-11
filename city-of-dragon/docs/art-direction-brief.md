# Art Direction Brief — City of Dragon: Epic Battle
Status: DRAFT v3 (2026-11-11) · Final: gaya pixel, strategi hybrid, Godot 4, Android + PC landscape, battle samping tim vs tim otomatis · Sisanya **usulan** sampai disetujui.

## Game frame
- Fantasi pemain: kumpulkan, besarkan, dan adu naga; bangun kota naga.
- Kata kerja inti: koleksi · evolusi · atur formasi · bangun kota.
- Battle: **otomatis** — naga sendiri yang menyerang, mengeluarkan jurus, menghindar, dan memblok. Pemain hanya memilih naga dan formasi.
- Engine: Godot 4 (renderer Compatibility, 2D).
- Platform: Android + PC, landscape.
- Kamera: battle tampak samping, tim vs tim (usulan 3 lawan 3; tim pemain di kiri hadap kanan, lawan di kanan hadap kiri — cukup satu arah sprite, lawan di-flip); kota tampak atas/top-down.
- Viewport (usulan): 640×360, skala integer (×3 = 1920×1080).
- Ukuran di layar: naga battle 64×64 (sprite 32×32 ditampilkan 2×); boss ±100×100; naga kota 16×16; ikon 32/34.

## Visual system
- Bentuk: siluet bulat-gemuk untuk bayi, runcing-bersayap lebar untuk dewasa.
- Siluet: elemen harus terbaca dari warna + 1 ciri bentuk (tanduk/sirip/sayap) pada 64px.
- Palet per elemen (usulan): Api merah-oranye · Air biru · Tanah cokelat-hijau · Udara putih-cyan · Es biru muda · Bayangan ungu-hitam · Racun hijau-limau · Kristal magenta · Emas kuning.
- Garis: outline gelap 1px, tanpa anti-alias, tanpa gradasi halus.
- Cahaya: dari kiri-atas.
- Animasi battle wajib per naga: `idle`, `attack`, `skill`, `dodge`, `block`, `hurt`, `death`. Idle 4–6 frame; lainnya 4–8 frame.
- Selama sprite belum lengkap: `dodge` = geser + transparan, `block` = kilat perisai, `hurt` = kedip putih — dibuat dari frame idle di engine, bukan gambar baru.
- Larangan: campur gaya lukis/vektor; sprite di-scale non-integer; teks di dalam gambar; desain mirip naga game lain.

## Technical contract
- Frame: 32×32 (battle, tampil 2×), 16×16 (kota). PNG, latar transparan. Skala selalu kelipatan bulat.
- Spritesheet: strip horizontal per animasi.
- Pivot: bawah-tengah.
- Godot import: Filter = Nearest, Mipmaps off, Compress = Lossless.
- Nama berkas naga saat ini = nama sumber (mis. `ice_dragon.png`); nama naga di game + elemen final dicatat di `assets/dragons/roster.json`.
- Folder:
  - `assets/dragons/` (+ `boss/`, `kecil/`, `roster.json`) · `assets/makhluk/` · `assets/eggs/` · `assets/ui/` · `assets/kota/` · `assets/bg/` · `assets/vfx/` · `assets/icons/`
  - Zip asli tidak disimpan; sumber + lisensi tiap pack ada di manifest dan `assets/CREDITS.md`.
- Catatan lisensi tiap berkas: `assets/asset-manifest.json`.

## Visual target
- Seed gaya: tile naga Dungeon Crawl Stone Soup 32×32 (CC0) — lihat `docs/pratinjau/naga.png`. Aset baru harus cocok dengan gaya ini.
- Persetujuan: pemilik proyek, tanggal: —
