# Markdown Viewer

A lightweight, fast, and beautiful Markdown viewer for macOS. View your `.md` files with GitHub-style rendering without leaving your desktop.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.1.2-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

- 🚀 **Lightweight** - Only ~1MB app size
- ⚡ **Fast** - Native Swift + WebKit rendering
- 🎨 **GitHub-style Markdown** - Beautiful rendering with proper formatting
- 🌓 **Auto Dark Mode** - Automatically adapts to your system theme
- ✏️ **Edit Mode** - Edit markdown source code with live preview
- 💾 **Save Changes** - Save your edits directly from the app
- 🔄 **Live Reload** - Refresh button to update file changes
- ⌨️ **Keyboard Shortcuts** - Quick file opening with ⌘O, save with ⌘S
- 📝 **Full Markdown Support** - Headers, lists, code blocks, links, and more
- 🎯 **File Association** - Set as default app for `.md` files

## 📸 Screenshots

*Coming soon*

## 🎯 Supported Markdown Features

- ✅ Headers (H1-H6)
- ✅ Bold, italic, strikethrough
- ✅ Inline code and code blocks with syntax highlighting
- ✅ Unordered and ordered lists
- ✅ Links
- ✅ Blockquotes
- ✅ Horizontal rules
- ✅ Proper paragraph spacing

## 📦 Installation

### Download

1. Go to [Releases](https://github.com/fiqihbadrian/Markdown-Viewer/releases)
2. Download the latest `MarkdownViewer-v1.0.0-macOS.dmg`
3. Open the DMG file
4. Drag `MarkdownViewer.app` to the `Applications` folder
5. Eject the DMG
6. Open MarkdownViewer from your Applications folder
7. Right-click the app and select "Open" (first time only, due to macOS Gatekeeper)

### Build from Source

Requirements:
- macOS 13.0 or later
- Xcode 15.0 or later

```bash
git clone https://github.com/fiqihbadrian/Markdown-Viewer.git
cd Markdown-Viewer
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer -configuration Release clean build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/MarkdownViewer-*/Build/Products/Release/MarkdownViewer.app`

## 🚀 Usage

### Opening Files

**Method 1: Double-click** (after setting as default app)
- Simply double-click any `.md` file

**Method 2: Drag & Drop**
- Drag a `.md` file onto the app icon

**Method 3: Right-click**
- Right-click a `.md` file → Open With → MarkdownViewer

**Method 4: From within the app**
- Open MarkdownViewer
- Press `⌘O` or use File → Open
- Select your markdown file

### Editing Markdown Files

**Preview Mode (Default)**
- Files open in preview mode by default
- Beautiful GitHub-style rendering
- Click **"Edit"** button to switch to edit mode

**Edit Mode**
- Click the **"Edit"** button in the toolbar
- Edit markdown source code with monospace font
- Press `⌘S` or click **"Save"** to save changes
- Click **"Preview"** to see rendered output
- Changes are saved to the original file

### Setting as Default App

**Option 1: Via App Menu**
1. Open MarkdownViewer
2. Go to menu: **MarkdownViewer → Set as Default App for .md Files**
3. Click **"Show .md File in Finder"**
4. Right-click the highlighted file → Get Info (⌘I)
5. Under "Open with:", select **MarkdownViewer**
6. Click **"Change All..."**

**Option 2: Via Finder**
1. Right-click any `.md` file
2. Select **"Get Info"** (or press ⌘I)
3. Under **"Open with:"**, choose **MarkdownViewer**
4. Click **"Change All..."** to apply to all `.md` files
5. Confirm the change

**Option 3: Via Info Button in App**
1. Open MarkdownViewer (without a file)
2. Click the **"How?"** button in the top banner
3. Follow the step-by-step instructions in the popup

### Keyboard Shortcuts

- `⌘O` - Open file
- `⌘S` - Save file (in edit mode)
- `⌘R` - Reload current file (refresh)
- `⌘W` - Close window
- `⌘Q` - Quit app

## 🛠️ Technical Details

- **Platform**: macOS 13.0+
- **Language**: Swift 6.1.2
- **UI Framework**: SwiftUI
- **Rendering**: WebKit
- **Size**: ~1MB
- **Memory Usage**: ~50MB when running

## 📋 System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel processor
- ~2MB disk space

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Known Issues

- Nested lists are not fully supported yet
- Tables are not rendered
- Images in markdown are not displayed

## 🗺️ Roadmap

- [ ] Add support for tables
- [ ] Add support for images
- [ ] Add support for nested lists
- [ ] Add export to PDF/HTML
- [ ] Add custom themes
- [ ] Add syntax highlighting for code blocks

## 💬 Support

If you encounter any issues or have questions:
- Open an [Issue](https://github.com/fiqihbadrian/Markdown-Viewer/issues)
- Check existing issues for solutions

## 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Inspired by GitHub's markdown rendering
- Icon design by [Your Name/Credit]

---

**Made with ❤️ by [Fiqih Badrian](https://github.com/fiqihbadrian)**

⭐ Star this repo if you find it useful!
