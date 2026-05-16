# Panduan Update Versi MarkdownViewer

## 📋 Cara Update dari v1.2.0 ke Versi Berikutnya (misal v1.3.0)

### Step 1: Update Kode & Build

1. **Buat perubahan kode** di Xcode
2. **Test** fitur baru
3. **Build Release**:
   ```bash
   cd ~/Documents/Project/APP/MarkdownViewer
   xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer -configuration Release clean build
   ```

### Step 2: Update ke /Applications

```bash
echo "0000" | sudo -S rm -rf /Applications/MarkdownViewer.app
echo "0000" | sudo -S cp -R ~/Library/Developer/Xcode/DerivedData/MarkdownViewer-*/Build/Products/Release/MarkdownViewer.app /Applications/
```

### Step 3: Buat DMG Baru

```bash
cd ~/Documents/Project/APP/MarkdownViewer

# Bersihkan folder temp
rm -rf /tmp/MarkdownViewer-dmg
mkdir -p /tmp/MarkdownViewer-dmg

# Copy app ke temp folder
cp -R /Applications/MarkdownViewer.app /tmp/MarkdownViewer-dmg/

# Buat DMG (ganti v1.3.0 dengan versi yang sesuai)
hdiutil create -volname "MarkdownViewer v1.3.0" \
  -srcfolder /tmp/MarkdownViewer-dmg \
  -ov -format UDZO \
  releases/MarkdownViewer-v1.3.0-macOS.dmg

# Cek ukuran DMG
ls -lh releases/*.dmg
```

### Step 4: Update CHANGELOG.md

Tambahkan entry baru di atas versi sebelumnya:

```markdown
## [1.3.0] - 2026-XX-XX

### Added
- Fitur baru 1
- Fitur baru 2

### Improved
- Improvement 1
- Improvement 2

### Fixed
- Bug fix 1
- Bug fix 2

### Technical
- Technical detail 1
- Technical detail 2
```

Jangan lupa update:
- Version Comparison table
- Download section (Latest version: **v1.3.0**)

### Step 5: Buat Release Notes

```bash
cd ~/Documents/Project/APP/MarkdownViewer/releases
```

Buat file baru: `RELEASE_NOTES_v1.3.0.md`

Template:
```markdown
# Release Notes - MarkdownViewer v1.3.0

## 🎉 What's New in v1.3.0

### 🆕 Fitur Baru 1
- Deskripsi fitur
- Cara menggunakan

### ✨ Improvement
- Deskripsi improvement

## 🚀 How to Use [Fitur Baru]

1. Step 1
2. Step 2
3. Step 3

## ✨ All Features

[List semua fitur termasuk yang lama]

## 📋 System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel processor
- ~2MB disk space

## 📦 Installation

1. Download `MarkdownViewer-v1.3.0-macOS.dmg`
2. Open the DMG file
3. Drag `MarkdownViewer.app` to the `Applications` folder
4. Eject the DMG
5. Open MarkdownViewer from Applications

## 🔄 Upgrading from Previous Versions

Simply replace the old app with the new one.

## 🙏 Thank You

Thank you for using MarkdownViewer!

---

**Download**: [MarkdownViewer-v1.3.0-macOS.dmg](https://github.com/fiqihbadrian/Markdown-Viewer/releases/download/v1.3.0/MarkdownViewer-v1.3.0-macOS.dmg)
```

### Step 6: Git Commit & Push

```bash
cd ~/Documents/Project/APP/MarkdownViewer

# Add semua perubahan
git add .

# Commit dengan pesan yang jelas
git commit -m "feat: Add [fitur baru] for v1.3.0

- Added [fitur 1]
- Added [fitur 2]
- Improved [improvement]
- Fixed [bug fix]

Technical:
- [technical detail]

Documentation:
- Updated CHANGELOG.md
- Added RELEASE_NOTES_v1.3.0.md"

# Push ke GitHub
git push origin main
```

### Step 7: Buat Git Tag

```bash
cd ~/Documents/Project/APP/MarkdownViewer

# Buat tag dengan annotated message
git tag -a v1.3.0 -m "Release v1.3.0 - [Judul Release]

New Features:
- [Fitur 1]
- [Fitur 2]

Improvements:
- [Improvement 1]
- [Improvement 2]

Bug Fixes:
- [Fix 1]
- [Fix 2]

Technical:
- [Technical detail]

Documentation:
- Updated documentation
- Added release notes"

# Push tag ke GitHub
git push origin v1.3.0
```

### Step 8: Buat GitHub Release

1. Buka: https://github.com/fiqihbadrian/Markdown-Viewer/releases/new
2. **Choose a tag**: Pilih `v1.3.0`
3. **Release title**: `MarkdownViewer v1.3.0 - [Judul Release]`
4. **Description**: Copy dari `RELEASE_NOTES_v1.3.0.md`
5. **Attach files**: Upload `MarkdownViewer-v1.3.0-macOS.dmg`
6. **Set as latest release**: ✅ Check
7. Klik **Publish release**

### Step 9: Verifikasi

Cek bahwa semua sudah benar:
- ✅ DMG bisa didownload
- ✅ App bisa dibuka tanpa error
- ✅ Fitur baru berfungsi
- ✅ Tag muncul di GitHub
- ✅ Release notes lengkap
- ✅ CHANGELOG.md updated

---

## 🔢 Version Numbering

Gunakan Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** (1.x.x): Breaking changes, redesign besar
- **MINOR** (x.1.x): Fitur baru, tidak breaking
- **PATCH** (x.x.1): Bug fixes, improvements kecil

Contoh:
- `v1.2.0` → `v1.3.0`: Fitur baru (PNG export)
- `v1.2.0` → `v1.2.1`: Bug fix saja
- `v1.2.0` → `v2.0.0`: Redesign besar / breaking changes

---

## 📝 Checklist Update Versi

Sebelum release, pastikan:

- [ ] Kode sudah di-test
- [ ] Build Release berhasil
- [ ] App di /Applications/ updated
- [ ] DMG dibuat dengan nama versi yang benar
- [ ] CHANGELOG.md updated
- [ ] RELEASE_NOTES_vX.X.X.md dibuat
- [ ] Git commit dengan pesan yang jelas
- [ ] Git tag dibuat
- [ ] Push ke GitHub (main branch + tag)
- [ ] GitHub Release dibuat
- [ ] DMG diupload ke GitHub Release
- [ ] Test download DMG dari GitHub
- [ ] Test install dari DMG

---

## 🎯 Contoh Lengkap: Update ke v1.3.0

```bash
# 1. Build
cd ~/Documents/Project/APP/MarkdownViewer
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer -configuration Release clean build

# 2. Update /Applications
echo "0000" | sudo -S rm -rf /Applications/MarkdownViewer.app
echo "0000" | sudo -S cp -R ~/Library/Developer/Xcode/DerivedData/MarkdownViewer-*/Build/Products/Release/MarkdownViewer.app /Applications/

# 3. Buat DMG
rm -rf /tmp/MarkdownViewer-dmg
mkdir -p /tmp/MarkdownViewer-dmg
cp -R /Applications/MarkdownViewer.app /tmp/MarkdownViewer-dmg/
hdiutil create -volname "MarkdownViewer v1.3.0" -srcfolder /tmp/MarkdownViewer-dmg -ov -format UDZO releases/MarkdownViewer-v1.3.0-macOS.dmg

# 4. Update CHANGELOG.md (manual edit)
# 5. Buat RELEASE_NOTES_v1.3.0.md (manual create)

# 6. Git commit
git add .
git commit -m "feat: Add image support for v1.3.0"
git push origin main

# 7. Git tag
git tag -a v1.3.0 -m "Release v1.3.0 - Image Support"
git push origin v1.3.0

# 8. Buat GitHub Release (via web)
# 9. Upload DMG ke GitHub Release
```

---

## 💡 Tips

1. **Selalu test** sebelum release
2. **Backup** versi lama sebelum update
3. **Dokumentasi lengkap** di release notes
4. **Semantic versioning** untuk clarity
5. **Git tag** untuk tracking
6. **GitHub Release** untuk distribution

---

**Current Version**: v1.2.0
**Next Version**: v1.3.0 (planned)
**Last Updated**: 16 Mei 2026
