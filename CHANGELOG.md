# Changelog

All notable changes to MarkdownViewer will be documented in this file.

## [1.1.0] - 2026-05-16

### Added
- **PNG Export Feature** 🎉
  - Export markdown to high-quality PNG images
  - Full CSS styling support (tables, code blocks, horizontal rules)
  - 5 theme support for PNG export
  - Auto-adjust height based on content
  - Proper margins and padding (60px body padding)
  - Success dialog with "Go to File" option
  - Export speed: 2-3 seconds
  - Output: 1200px width with dynamic height

### Improved
- **Table Rendering**
  - Added full border support (2px outer, 1px cells)
  - Header styling with background color
  - Zebra striping for better readability
  - Border-radius 8px for modern look

- **Code Block Styling**
  - Background color support
  - Border 2px solid
  - Border-radius 8px
  - Proper padding (16px)
  - Monospace font

- **Horizontal Rules**
  - Border 3px solid (clearly visible)
  - Proper margin (24px top/bottom)
  - Theme-aware colors

- **Documentation**
  - Added PNG_EXPORT_FEATURE.md
  - Added SUMMARY_PNG_EXPORT.md
  - Added TODO_PDF_IMPROVEMENT.md
  - Added UPDATE_NOTES.md
  - Added HOW_TO_TEST.md
  - Updated README.md with PNG export info

### Technical
- Implemented WKWebView-based rendering
- JavaScript evaluation for content height calculation
- WKSnapshotConfiguration for image capture
- NSBitmapImageRep for PNG conversion
- Proper memory management (WebView cleanup)

## [1.0.0] - 2026-05-15

### Added
- Initial release
- Markdown preview with GitHub-style rendering
- Edit mode with syntax highlighting
- 5 preview themes (System, GitHub Light/Dark, Light, Dark)
- PDF export (basic)
- Save functionality
- File association support
- Keyboard shortcuts (⌘O, ⌘S, ⌘R)
- Dark mode support

### Features
- Headers (H1-H6)
- Bold, italic, strikethrough
- Inline code and code blocks
- Unordered and ordered lists
- Links
- Blockquotes
- Horizontal rules
- Tables (basic rendering)

---

## Version Comparison

| Feature | v1.0.0 | v1.1.0 |
|---------|--------|--------|
| Markdown Preview | ✅ | ✅ |
| Edit Mode | ✅ | ✅ |
| Themes | ✅ 5 themes | ✅ 5 themes |
| PDF Export | ✅ Basic | ✅ Basic |
| PNG Export | ❌ | ✅ **NEW** |
| Table Borders | ⚠️ Preview only | ✅ Full support |
| Code Block BG | ⚠️ Preview only | ✅ Full support |
| Horizontal Rules | ⚠️ Preview only | ✅ Full support |

---

## Upcoming Features

### [1.2.0] - Planned
- [ ] Image support in markdown
- [ ] Nested lists support
- [ ] Improved PDF export with full CSS
- [ ] Configurable PNG export (width, DPI)
- [ ] Batch export multiple files

### [1.3.0] - Planned
- [ ] Custom themes (user-defined)
- [ ] Export to HTML
- [ ] Syntax highlighting for code blocks
- [ ] Markdown templates
- [ ] Recent files menu

### [2.0.0] - Future
- [ ] Plugin system
- [ ] Live collaboration
- [ ] Cloud sync
- [ ] Mobile companion app
- [ ] Advanced markdown extensions

---

## Download

Latest version: **v1.1.0**
- [Download from GitHub Releases](https://github.com/fiqihbadrian/Markdown-Viewer/releases)

## Feedback

Found a bug or have a feature request?
- [Open an issue](https://github.com/fiqihbadrian/Markdown-Viewer/issues)
- [Discussions](https://github.com/fiqihbadrian/Markdown-Viewer/discussions)

---

**Made with ❤️ by [Fiqih Badrian](https://github.com/fiqihbadrian)**
