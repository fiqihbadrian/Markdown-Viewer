# MarkdownViewer (Windows & Linux)

Versi lintas platform berbasis [Tauri 2](https://tauri.app). Backend memakai Rust,
tampilan memakai WebView bawaan sistem (WebView2 di Windows, WebKitGTK di Linux).
Karena tidak membawa mesin browser sendiri, ukuran installer jauh lebih kecil
dibanding versi Electron.

## Fitur
- Buka dan baca file `.md` / `.markdown`
- Edit dan simpan (Ctrl+S)
- Tema: System, Light, Dark, GitHub Light, GitHub Dark
- Ekspor PDF lewat dialog cetak sistem
- Ekspor PNG seluruh isi preview (bukan hanya yang terlihat)
- Satu jendela saja, dan bisa membuka file `.md` dari Explorer

## Pintasan
| Tombol | Aksi |
| --- | --- |
| Ctrl+O | Buka file |
| Ctrl+E | Ganti edit / preview |
| Ctrl+S | Simpan |

## Pengembangan
```bash
npm install
npm run dev      # jalankan app
npm run build    # buat installer
```

## Build rilis
Windows dan Linux dibangun lewat GitHub Actions
(`.github/workflows/build-desktop.yml`), karena Tauri perlu runner sesuai
sistem operasinya. Jalankan workflow `build-desktop` secara manual, atau push
tag `v*`.
