# Cara Test Aplikasi Markdown Viewer dengan Fitur Baru

## ⚠️ Aplikasi Perlu Di-Rebuild

Kode sudah diupdate di:
`/Users/macbook/Documents/project/app/MarkdownViewer/MarkdownViewer/ContentView.swift`

Tapi aplikasi yang terinstall di `/Applications/MarkdownViewer.app` masih menggunakan kode lama.

## 🔨 Cara Rebuild Aplikasi:

### Opsi 1: Menggunakan Xcode (Recommended)
1. Buka Xcode
2. Open project: `/Users/macbook/Documents/project/app/MarkdownViewer/MarkdownViewer.xcodeproj`
3. Pilih target: **MarkdownViewer**
4. Klik **Product → Build** (⌘B)
5. Klik **Product → Run** (⌘R) untuk test
6. Atau **Product → Archive** untuk membuat distribusi

### Opsi 2: Menggunakan xcodebuild (Command Line)
```bash
cd /Users/macbook/Documents/project/app/MarkdownViewer
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer -configuration Release build
```

**Note**: Ini memerlukan Xcode terinstall penuh, bukan hanya Command Line Tools.

## 📝 File Test Sudah Disiapkan

File test markdown sudah dibuat di:
`/Users/macbook/Documents/test_markdown_viewer.md`

Setelah rebuild, buka file ini dengan MarkdownViewer untuk test:
- ✅ Theme selector (GitHub, White, Dark)
- ✅ PDF export button
- ✅ "Go to File" button setelah export

## 🎯 Yang Harus Ditest:

### 1. Theme Selector
- Buka file markdown
- Klik icon **paintbrush** di toolbar
- Pilih tema: GitHub / White (Print) / Dark Mode
- Lihat perubahan styling

### 2. PDF Export
- Klik tombol **PDF** di toolbar
- Tunggu proses export
- Alert akan muncul dengan lokasi file PDF

### 3. Go to File
- Setelah alert muncul
- Klik tombol **"Go to File"**
- Finder akan terbuka dan highlight file PDF

## 📂 Lokasi File Penting:

- **Source Code**: `/Users/macbook/Documents/project/app/MarkdownViewer/MarkdownViewer/ContentView.swift`
- **Project**: `/Users/macbook/Documents/project/app/MarkdownViewer/MarkdownViewer.xcodeproj`
- **Installed App**: `/Applications/MarkdownViewer.app`
- **Test File**: `/Users/macbook/Documents/test_markdown_viewer.md`
- **Backup**: `/Users/macbook/Documents/project/app/MarkdownViewer/MarkdownViewer/ContentView.swift.backup`

## 🐛 Jika Ada Error:

1. **Build Error**: Cek syntax di ContentView.swift
2. **Import Error**: Pastikan `import PDFKit` ada di bagian atas
3. **Theme tidak muncul**: Pastikan enum PreviewTheme sudah ada
4. **PDF tidak ter-generate**: Cek permission folder

## 💡 Tips:

- Setelah rebuild, restart aplikasi jika sudah terbuka
- Test dengan file markdown yang berbeda-beda
- Coba export PDF dengan tema yang berbeda
- PDF akan tersimpan di folder yang sama dengan file .md

---

**Status**: Kode sudah siap, tinggal rebuild aplikasi! 🚀
