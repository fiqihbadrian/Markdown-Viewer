# Release Notes - MarkdownViewer v1.2.0

## 🎉 What's New in v1.2.0

### 🖼️ PNG Export Feature (NEW!)
- **Export to PNG** with full styling support
- Click the **"PNG"** button in toolbar to export
- Features:
  - ✅ Table borders with zebra striping
  - ✅ Code block backgrounds and borders
  - ✅ Horizontal rules (3px solid)
  - ✅ All theme colors applied
  - ✅ Proper margins and padding (60px)
  - ✅ Auto-adjust height based on content
  - ✅ High-quality output (1200px width)
- Success dialog with "Go to File" option
- Export speed: 2-3 seconds
- Output saved to same folder as .md file

### 🎨 5 Beautiful Preview Themes
- **System Default** - Auto adapts to macOS light/dark mode
- **GitHub Light** - Classic GitHub light theme
- **GitHub Dark** - GitHub's dark theme
- **Light** - Clean light theme with high contrast
- **Dark** - Modern dark theme
- Theme selector in toolbar with paintbrush icon
- Themes apply to both preview and PNG export

### 📊 Enhanced Table Rendering
- Tables now render with proper borders
- Header row styling with background color
- Better cell padding and spacing
- Zebra striping for better readability
- Border-radius 8px for modern look
- Full support in PNG export

### 💻 Better Code Block Styling
- Background color support
- Border 2px solid with border-radius 8px
- Enhanced code block appearance
- Better contrast and readability
- Proper padding (16px) and margins
- Monospace font (SF Mono, Monaco)

### ➖ Horizontal Rules
- Now visible with 3px solid border
- Proper margin (24px top/bottom)
- Theme-aware colors
- Clear visual separation

### 🎯 UI Improvements
- Added PNG export button in toolbar
- Loading indicators for export operations
- Cleaner toolbar layout with dividers
- Better button organization
- Improved visual hierarchy
- Professional toolbar design

### 📄 PDF Export (Existing)
- Export to PDF with basic styling
- Small file size
- Text remains selectable
- Perfect for printing

## 🚀 How to Use PNG Export

1. Open any .md file in MarkdownViewer
2. Choose your preferred theme (optional)
3. Click the **"PNG"** button in the toolbar
4. Wait 2-3 seconds for export to complete
5. PNG file will be saved in the same folder as your .md file
6. Click **"Go to File"** in success dialog to view the PNG

## ✨ All Features

- **Lightweight & Fast** - Only ~1.2MB app size with native Swift performance
- **GitHub-style Rendering** - Beautiful markdown rendering
- **Edit & Preview** - Toggle between editing source and viewing rendered markdown
- **5 Preview Themes** - Choose your favorite theme
- **PNG Export** - Export with full styling support
- **PDF Export** - Export for printing and sharing
- **Dark Mode Support** - Automatically adapts to your system
- **Full Markdown Support**:
  - Headers (H1-H6)
  - Bold, italic, strikethrough text
  - Inline code and code blocks
  - Unordered and ordered lists
  - Links and blockquotes
  - Horizontal rules
  - Tables with borders
- **Easy File Association** - Built-in helper to set as default app for `.md` files
- **Keyboard Shortcuts** - ⌘O to open, ⌘S to save, ⌘R to reload
- **Save Changes** - Edit and save markdown files directly

## 📋 System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel processor
- ~2MB disk space

## 📦 Installation

1. Download `MarkdownViewer-v1.2.0-macOS.dmg`
2. Open the DMG file
3. Drag `MarkdownViewer.app` to the `Applications` folder
4. Eject the DMG
5. Open MarkdownViewer from Applications
6. Right-click and select "Open" (first time only, due to macOS Gatekeeper)

## 🔄 Upgrading from Previous Versions

Simply replace the old app with the new one. Your settings and preferences will be preserved.

**From v1.0.0 or v1.1.0:**
- Drag the new app to Applications folder
- Replace when prompted
- All your settings will be kept

## 📊 File Size

- App Size: ~1.2MB (DMG)
- PNG Export: 1-5MB depending on content length
- PDF Export: <1MB for most documents

## 🐛 Bug Fixes

- Fixed theme switching in preview mode
- Improved markdown parsing for edge cases
- Better handling of empty lines
- Fixed table rendering in exports
- Improved memory management for exports

## 🔜 Coming Soon (v1.3.0)

- Image support in markdown
- Nested lists support
- Improved PDF export with full CSS
- Configurable PNG export (width, DPI)
- Batch export multiple files
- Custom themes (user-defined)

## 📊 Comparison: PNG vs PDF Export

| Feature | PNG Export | PDF Export |
|---------|-----------|-----------|
| Table borders | ✅ Perfect | ⚠️ Limited |
| Code block bg | ✅ Perfect | ⚠️ Limited |
| Horizontal rules | ✅ Perfect | ⚠️ Limited |
| Theme support | ✅ 5 themes | ⚠️ Basic |
| File size | Medium (1-5MB) | Small (<1MB) |
| Text selection | ❌ No | ✅ Yes |
| Print quality | Good (72 DPI) | Excellent (vector) |
| Web sharing | ✅ Perfect | ⚠️ Depends |

## 🙏 Thank You

Thank you for using MarkdownViewer! If you encounter any issues or have feature requests, please report them on GitHub.

---

**Download**: [MarkdownViewer-v1.2.0-macOS.dmg](https://github.com/fiqihbadrian/Markdown-Viewer/releases/download/v1.2.0/MarkdownViewer-v1.2.0-macOS.dmg)

**Full Changelog**: [CHANGELOG.md](https://github.com/fiqihbadrian/Markdown-Viewer/blob/main/CHANGELOG.md)

**GitHub Repository**: [fiqihbadrian/Markdown-Viewer](https://github.com/fiqihbadrian/Markdown-Viewer)
