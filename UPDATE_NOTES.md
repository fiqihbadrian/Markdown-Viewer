# Markdown Viewer - Update Notes

## Update Date: 2026-05-16

### New Features Added:

#### 1. **PDF Export Functionality**
- Added "PDF" button in the toolbar
- Converts current markdown file to PDF
- PDF saved in the same directory as the markdown file
- Uses selected theme for PDF styling

#### 2. **Theme Selector (3 Themes)**
- **GitHub Theme**: Classic GitHub markdown style (default)
- **White (Print) Theme**: Clean white background with black text, perfect for printing
- **Dark Mode Theme**: Dark background with light text

Theme selector appears in toolbar (only in preview mode)

#### 3. **PDF Export Success Dialog**
- Shows alert when PDF is successfully exported
- Displays the full path where PDF was saved
- Two buttons:
  - **OK**: Close the dialog
  - **Go to File**: Opens Finder and highlights the exported PDF file

### Technical Changes:

#### New Components:
- `PreviewTheme` enum: Defines available themes
- `MarkdownConverter` class: Static helper class for markdown to HTML conversion
- Theme-specific CSS generation in `getThemeCSS()`

#### Updated Components:
- `ContentView`: Added theme selector, PDF export button, and success alert
- `MarkdownWebView`: Now accepts theme parameter
- Added `@State` variables:
  - `selectedTheme`: Current preview theme
  - `showingPDFSuccess`: Controls PDF success alert
  - `lastPDFPath`: Stores path of last exported PDF

#### New Functions:
- `exportToPDF()`: Generates PDF from markdown content
- `showPDFError()`: Displays error alert if PDF export fails
- `revealPDFInFinder()`: Opens Finder and selects the exported PDF

### How to Use:

1. **Change Theme**: Click the theme button (paintbrush icon) in toolbar and select desired theme
2. **Export to PDF**: Click the "PDF" button in toolbar
3. **Find Exported PDF**: Click "Go to File" in success dialog to open Finder

### File Structure:
```
ContentView.swift
├── PreviewTheme enum
├── ContentView struct
├── MarkdownConverter class (helper)
├── MarkdownWebView struct
├── DefaultAppInfoView struct
├── InstructionStep struct
└── MarkdownEditor struct
```

### Notes:
- PDF export uses WKWebView's built-in PDF generation
- PDF size is A4 (595x842 points)
- Theme selection only affects preview and PDF export, not the source markdown file
- All themes are optimized for readability
