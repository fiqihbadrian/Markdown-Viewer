# TODO: PDF Export Improvement

## Status Saat Ini (16 Mei 2026 - 00:40)

### ✅ Yang Sudah Berhasil:
1. **Table Support** - Table markdown di-render sebagai HTML table dengan border di preview
2. **5 Tema Preview** - System Default, GitHub Light/Dark, Light, Dark (semua bekerja sempurna)
3. **PDF Export** - Berfungsi dan cepat, tapi styling terbatas:
   - ✅ Text content ada
   - ✅ Heading, list, blockquote
   - ❌ Table border tidak muncul di PDF
   - ❌ Code block background tidak muncul di PDF
   - ❌ Horizontal rule tidak muncul di PDF

### 🔧 Masalah:
NSAttributedString (yang dipakai sekarang) punya keterbatasan dalam render CSS:
- Tidak support `border` property untuk table
- Tidak support `background-color` untuk code block
- Tidak support `border-top` untuk horizontal rule

### 🎯 Solusi untuk Besok:

#### **Opsi 1: Gunakan Library "Down" (RECOMMENDED)**
Library Swift yang mature untuk Markdown to PDF dengan styling penuh.

**Langkah-langkah:**
1. Tambahkan Down via Swift Package Manager:
   - URL: `https://github.com/johnxnguyen/Down`
   - Version: `0.11.0`
2. Import Down di ContentView.swift
3. Ganti fungsi `exportToPDF()` dengan:
   ```swift
   let down = Down(markdownString: markdownContent)
   let pdfData = try? down.toPDF()
   try pdfData?.write(to: pdfURL)
   ```

**Kelebihan:**
- ✅ Full CSS support (table border, code block background, dll)
- ✅ Mature dan well-maintained
- ✅ Mudah digunakan
- ✅ Support syntax highlighting untuk code block

**Kekurangan:**
- Perlu setup Swift Package Manager
- Tambahan dependency

---

#### **Opsi 2: Buat Custom PDF Renderer dengan PDFKit**
Render markdown secara manual menggunakan PDFKit untuk kontrol penuh.

**Langkah-langkah:**
1. Parse markdown line by line
2. Untuk setiap elemen (heading, paragraph, table, code block):
   - Hitung posisi dan ukuran
   - Draw langsung ke PDF context dengan PDFKit
3. Handle table dengan draw border manual
4. Handle code block dengan draw background manual

**Kelebihan:**
- ✅ Kontrol penuh atas styling
- ✅ Tidak perlu library eksternal
- ✅ Bisa custom sesuai kebutuhan

**Kekurangan:**
- ❌ Butuh waktu development lama (estimasi 4-6 jam)
- ❌ Harus handle semua edge case manual
- ❌ Maintenance lebih ribet

---

#### **Opsi 3: Hybrid - WKWebView Screenshot to PDF**
Render HTML di WKWebView, screenshot, convert ke PDF.

**Status:** Sudah dicoba, tapi ada masalah:
- WKWebView.createPDF() → error "unknown error"
- WKWebView.takeSnapshot() → loading loop
- NSPrintOperation → aplikasi freeze/crash

**Kesimpulan:** Tidak reliable untuk production.

---

## Rekomendasi Final:

**Gunakan Opsi 1 (Library Down)** karena:
1. Paling cepat diimplementasi (estimasi 30 menit)
2. Paling reliable dan tested
3. Full feature support
4. Easy maintenance

## File yang Perlu Dimodifikasi:
1. `MarkdownViewer.xcodeproj` - Tambah Down package
2. `ContentView.swift` - Update fungsi `exportToPDF()`

## Testing Checklist:
- [ ] Table dengan border muncul di PDF
- [ ] Code block dengan background muncul di PDF
- [ ] Horizontal rule muncul di PDF
- [ ] Heading, list, blockquote tetap bekerja
- [ ] Bold, italic, link tetap bekerja
- [ ] PDF file size reasonable (< 5MB untuk dokumen normal)
- [ ] Export cepat (< 2 detik)

---

**Catatan:** Versi saat ini sudah stabil untuk preview dan basic PDF export. Tinggal improve styling PDF saja.
