import SwiftUI
import WebKit
import PDFKit

enum PreviewTheme: String, CaseIterable {
    case system = "System Default"
    case githubLight = "GitHub Light"
    case githubDark = "GitHub Dark"
    case light = "Light"
    case dark = "Dark"
}

struct ContentView: View {
    @State private var markdownContent: String = "# Welcome to Markdown Viewer\n\nDouble-click any `.md` file to open it here.\n\nOr use **⌘O** to open a file.\n\n---\n\n## Set as Default App\n\nTo make MarkdownViewer your default app for .md files:\n\n1. Go to menu: **MarkdownViewer → Set as Default App for .md Files**\n2. Or right-click any .md file → Get Info (⌘I)\n3. Under 'Open with:', choose MarkdownViewer\n4. Click 'Change All...'"
    @State private var currentFileURL: URL?
    @State private var showingDefaultAppInfo = false
    @State private var isEditMode = false
    @State private var editableContent: String = ""
    @State private var selectedTheme: PreviewTheme = .system
    @State private var showingPDFSuccess = false
    @State private var lastPDFPath: String = ""
    @State private var isExportingPDF = false
    @State private var showingPNGSuccess = false
    @State private var lastPNGPath: String = ""
    @State private var isExportingPNG = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            if let url = currentFileURL {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text(url.lastPathComponent)
                        .font(.headline)
                    Spacer()
                    
                    // Theme selector (only in preview mode)
                    if !isEditMode {
                        Menu {
                            ForEach(PreviewTheme.allCases, id: \.self) { theme in
                                Button(action: { selectedTheme = theme }) {
                                    HStack {
                                        Text(theme.rawValue)
                                        if selectedTheme == theme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "paintbrush")
                                Text(selectedTheme.rawValue)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("Change preview theme")
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 8)
                    }
                    
                    // Edit/Preview toggle button
                    Button(action: toggleEditMode) {
                        HStack(spacing: 4) {
                            Image(systemName: isEditMode ? "eye" : "pencil")
                            Text(isEditMode ? "Preview" : "Edit")
                        }
                    }
                    .buttonStyle(.plain)
                    .help(isEditMode ? "Switch to preview mode" : "Edit markdown source")
                    
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 8)
                    
                    // Save button (only in edit mode)
                    if isEditMode {
                        Button(action: saveFile) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save")
                            }
                        }
                        .buttonStyle(.plain)
                        .help("Save changes (⌘S)")
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 8)
                    }
                    
                    Button(action: reloadFile) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Reload file")
                    
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 8)
                    
                    // Export to PDF button
                    Button(action: {
                        isExportingPDF = true
                        exportToPDF()
                    }) {
                        HStack(spacing: 4) {
                            if isExportingPDF {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "arrow.down.doc")
                            }
                            Text(isExportingPDF ? "Exporting..." : "PDF")
                        }
                    }
                    .disabled(isExportingPDF)
                    .buttonStyle(.plain)
                    .help("Export to PDF")
                    
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 8)
                    
                    // Export to PNG button
                    Button(action: {
                        isExportingPNG = true
                        exportToPNG()
                    }) {
                        HStack(spacing: 4) {
                            if isExportingPNG {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "photo")
                            }
                            Text(isExportingPNG ? "Exporting..." : "PNG")
                        }
                    }
                    .disabled(isExportingPNG)
                    .buttonStyle(.plain)
                    .help("Export to PNG")
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                Divider()
            } else {
                // Show info banner when no file is open
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Tip: Set as default app from menu")
                        .font(.subheadline)
                    Spacer()
                    Button("How?") {
                        showingDefaultAppInfo = true
                    }
                    .buttonStyle(.link)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                Divider()
            }
            
            // Content area - either editor or preview
            if isEditMode {
                MarkdownEditor(text: $editableContent)
            } else {
                MarkdownWebView(markdownContent: markdownContent, theme: selectedTheme)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .onReceive(NotificationCenter.default.publisher(for: .openMarkdownFile)) { notification in
            if let url = notification.object as? URL {
                loadMarkdownFile(url: url)
            }
        }
        .sheet(isPresented: $showingDefaultAppInfo) {
            DefaultAppInfoView()
        }
        .alert("PDF Exported Successfully", isPresented: $showingPDFSuccess) {
            Button("OK", role: .cancel) { }
            Button("Go to File") {
                revealPDFInFinder()
            }
        } message: {
            Text("PDF saved to: \(lastPDFPath)")
        }
        .alert("PNG Exported Successfully", isPresented: $showingPNGSuccess) {
            Button("OK", role: .cancel) { }
            Button("Go to File") {
                revealPNGInFinder()
            }
        } message: {
            Text("PNG saved to: \(lastPNGPath)")
        }
    }
    
    func loadMarkdownFile(url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            markdownContent = content
            editableContent = content
            currentFileURL = url
            isEditMode = false
        } catch {
            markdownContent = "# Error\n\nCould not load file: \(error.localizedDescription)"
        }
    }
    
    func toggleEditMode() {
        isEditMode.toggle()
        if isEditMode {
            editableContent = markdownContent
        }
    }
    
    func reloadFile() {
        guard let url = currentFileURL else { return }
        loadMarkdownFile(url: url)
    }
    
    func saveFile() {
        guard let url = currentFileURL else { return }
        
        do {
            try editableContent.write(to: url, atomically: true, encoding: .utf8)
            markdownContent = editableContent
            
            let alert = NSAlert()
            alert.messageText = "File Saved"
            alert.informativeText = "Your changes have been saved successfully."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Save Failed"
            alert.informativeText = "Could not save file: \(error.localizedDescription)"
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func exportToPDF() {
        guard let url = currentFileURL else { 
            isExportingPDF = false
            return 
        }
        
        let pdfFileName = url.deletingPathExtension().lastPathComponent + ".pdf"
        let pdfURL = url.deletingLastPathComponent().appendingPathComponent(pdfFileName)
        
        // Use simple HTML with inline styles for NSAttributedString
        let html = MarkdownConverter.convertToHTMLForPDF(markdownContent)
        
        guard let htmlData = html.data(using: .utf8) else {
            isExportingPDF = false
            showPDFError("Failed to convert HTML to data")
            return
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            isExportingPDF = false
            showPDFError("Failed to parse HTML")
            return
        }
        
        let printInfo = NSPrintInfo.shared
        printInfo.paperSize = NSSize(width: 595, height: 842)
        printInfo.leftMargin = 50
        printInfo.rightMargin = 50
        printInfo.topMargin = 50
        printInfo.bottomMargin = 50
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 495, height: 742))
        textView.textStorage?.setAttributedString(attributedString)
        
        let pdfData = textView.dataWithPDF(inside: textView.bounds)
        
        do {
            try pdfData.write(to: pdfURL)
            self.isExportingPDF = false
            self.lastPDFPath = pdfURL.path
            self.showingPDFSuccess = true
        } catch {
            self.isExportingPDF = false
            self.showPDFError("Could not save PDF: \(error.localizedDescription)")
        }
    }
    
    func showPDFError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "PDF Export Failed"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func revealPDFInFinder() {
        let url = URL(fileURLWithPath: lastPDFPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    func exportToPNG() {
        guard let url = currentFileURL else { 
            isExportingPNG = false
            return 
        }
        
        let pngFileName = url.deletingPathExtension().lastPathComponent + ".png"
        let pngURL = url.deletingLastPathComponent().appendingPathComponent(pngFileName)
        
        // Create HTML with proper styling for PNG export
        let html = MarkdownConverter.convertToHTMLForPNG(markdownContent, theme: selectedTheme)
        
        // Create a hidden WKWebView for rendering
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 1600), configuration: config)
        webView.isHidden = true
        
        // Add to window to ensure proper rendering
        if let window = NSApplication.shared.windows.first {
            window.contentView?.addSubview(webView)
        }
        
        webView.loadHTMLString(html, baseURL: nil)
        
        // Wait for content to load, then capture
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Calculate actual content height
            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                let contentHeight = (result as? CGFloat) ?? 1600
                let finalHeight = max(contentHeight + 100, 800) // Add padding and minimum height
                
                // Resize webview to fit content
                webView.frame = CGRect(x: 0, y: 0, width: 1200, height: finalHeight)
                
                // Small delay to ensure resize is applied
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let config = WKSnapshotConfiguration()
                    config.rect = CGRect(x: 0, y: 0, width: 1200, height: finalHeight)
                    
                    webView.takeSnapshot(with: config) { image, error in
                        webView.removeFromSuperview()
                        
                        if let error = error {
                            self.isExportingPNG = false
                            self.showPNGError("Failed to capture image: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let image = image else {
                            self.isExportingPNG = false
                            self.showPNGError("Failed to create image")
                            return
                        }
                        
                        // Convert NSImage to PNG data
                        guard let tiffData = image.tiffRepresentation,
                              let bitmapImage = NSBitmapImageRep(data: tiffData),
                              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                            self.isExportingPNG = false
                            self.showPNGError("Failed to convert image to PNG")
                            return
                        }
                        
                        do {
                            try pngData.write(to: pngURL)
                            self.isExportingPNG = false
                            self.lastPNGPath = pngURL.path
                            self.showingPNGSuccess = true
                        } catch {
                            self.isExportingPNG = false
                            self.showPNGError("Could not save PNG: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func showPNGError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "PNG Export Failed"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func revealPNGInFinder() {
        let url = URL(fileURLWithPath: lastPNGPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

// Markdown Converter Helper Class
class MarkdownConverter {
    static func convertToHTML(_ markdown: String, theme: PreviewTheme) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var codeBlockContent = ""
        var inList = false
        var inTable = false
        var tableRows: [String] = []
        
        for i in 0..<lines.count {
            var line = lines[i]
            
            if line.hasPrefix("```") {
                if inTable { html += processTable(tableRows); tableRows = []; inTable = false }
                if inCodeBlock {
                    html += "<pre><code>\(escapeHTML(codeBlockContent))</code></pre>"
                    codeBlockContent = ""
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockContent += line + "\n"
                continue
            }
            
            if line.contains("|") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !inTable {
                    inTable = true
                }
                tableRows.append(line)
                continue
            } else {
                if inTable {
                    html += processTable(tableRows)
                    tableRows = []
                    inTable = false
                }
            }
            
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if inList {
                    html += "</ul>"
                    inList = false
                }
                html += "<p></p>"
                continue
            }
            
            if line.hasPrefix("# ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<h1>\(processInlineMarkdown(line))</h1>"
            } else if line.hasPrefix("## ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(3))
                html += "<h2>\(processInlineMarkdown(line))</h2>"
            } else if line.hasPrefix("### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(4))
                html += "<h3>\(processInlineMarkdown(line))</h3>"
            } else if line.hasPrefix("#### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(5))
                html += "<h4>\(processInlineMarkdown(line))</h4>"
            } else if line.hasPrefix("##### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(6))
                html += "<h5>\(processInlineMarkdown(line))</h5>"
            } else if line.hasPrefix("###### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(7))
                html += "<h6>\(processInlineMarkdown(line))</h6>"
            }
            else if line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___") {
                if inList { html += "</ul>"; inList = false }
                html += "<hr>"
            }
            else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                if !inList {
                    html += "<ul>"
                    inList = true
                }
                line = String(line.dropFirst(2))
                html += "<li>\(processInlineMarkdown(line))</li>"
            }
            else if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                if !inList {
                    html += "<ol>"
                    inList = true
                }
                if let match = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                    line = String(line[match.upperBound...])
                }
                html += "<li>\(processInlineMarkdown(line))</li>"
            }
            else if line.hasPrefix("> ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<blockquote>\(processInlineMarkdown(line))</blockquote>"
            }
            else {
                if inList { html += "</ul>"; inList = false }
                html += "<p>\(processInlineMarkdown(line))</p>"
            }
        }
        
        if inList {
            html += "</ul>"
        }
        
        if inTable {
            html += processTable(tableRows)
        }
        
        let cssStyle = getThemeCSS(theme: theme)
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                \(cssStyle)
            </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
    
    static func processTable(_ rows: [String]) -> String {
        guard !rows.isEmpty else { return "" }
        
        var html = "<table>"
        var isHeader = true
        
        for row in rows {
            let trimmed = row.trimmingCharacters(in: .whitespaces)
            let isSeparator = trimmed.replacingOccurrences(of: "|", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ":", with: "")
                .isEmpty
            
            if isSeparator {
                isHeader = false
                continue
            }
            
            let cells = row.split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if cells.isEmpty { continue }
            
            if isHeader {
                html += "<thead><tr>"
                for cell in cells {
                    html += "<th>\(processInlineMarkdown(cell))</th>"
                }
                html += "</tr></thead><tbody>"
                isHeader = false
            } else {
                html += "<tr>"
                for cell in cells {
                    html += "<td>\(processInlineMarkdown(cell))</td>"
                }
                html += "</tr>"
            }
        }
        
        html += "</tbody></table>"
        return html
    }
    
    static func getThemeCSS(theme: PreviewTheme) -> String {
        let baseCSS = """
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                line-height: 1.6;
                padding: 30px;
                max-width: 980px;
                margin: 0 auto;
                font-size: 16px;
            }
            h1, h2, h3, h4, h5, h6 {
                margin-top: 24px;
                margin-bottom: 16px;
                font-weight: 600;
                line-height: 1.25;
            }
            h1 { font-size: 2em; padding-bottom: 0.3em; margin-top: 0; }
            h2 { font-size: 1.5em; padding-bottom: 0.3em; }
            h3 { font-size: 1.25em; }
            h4 { font-size: 1em; }
            h5 { font-size: 0.875em; }
            h6 { font-size: 0.85em; }
            p { margin-top: 0; margin-bottom: 16px; }
            code {
                padding: 0.2em 0.4em;
                border-radius: 6px;
                font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, monospace;
                font-size: 85%;
            }
            pre {
                padding: 16px;
                border-radius: 6px;
                overflow: auto;
                line-height: 1.45;
                margin-bottom: 16px;
            }
            pre code {
                background-color: transparent;
                padding: 0;
                border-radius: 0;
                font-size: 85%;
                display: block;
            }
            a { text-decoration: none; }
            a:hover { text-decoration: underline; }
            ul, ol { margin-top: 0; margin-bottom: 16px; padding-left: 2em; }
            li { margin-top: 0.25em; }
            blockquote { margin: 0 0 16px 0; padding: 0 1em; }
            hr { height: 0.25em; padding: 0; margin: 24px 0; border: 0; }
            strong { font-weight: 600; }
            em { font-style: italic; }
            table {
                border-collapse: collapse;
                width: 100%;
                margin-bottom: 16px;
                display: block;
                overflow: auto;
            }
            table th, table td {
                padding: 6px 13px;
                border: 1px solid;
            }
            table th {
                font-weight: 600;
                text-align: left;
            }
            table tr {
                border-top: 1px solid;
            }
        """
        
        switch theme {
        case .system:
            return baseCSS + """
                @media (prefers-color-scheme: light) {
                    body { background-color: #ffffff; color: #000000; }
                    h1, h2 { border-bottom: 1px solid #e0e0e0; }
                    h6 { color: #666666; }
                    code { background-color: #f5f5f5; border: 1px solid #e0e0e0; }
                    pre { background-color: #f9f9f9; border: 1px solid #e0e0e0; }
                    a { color: #007AFF; }
                    blockquote { color: #666666; border-left: 0.25em solid #e0e0e0; background-color: #fafafa; }
                    hr { background-color: #e0e0e0; }
                    table th, table td { border-color: #e0e0e0; }
                    table tr { border-top-color: #e0e0e0; background-color: #ffffff; }
                    table tr:nth-child(2n) { background-color: #f9f9f9; }
                    table th { background-color: #f5f5f5; }
                }
                @media (prefers-color-scheme: dark) {
                    body { background-color: #1e1e1e; color: #d4d4d4; }
                    h1, h2 { border-bottom: 1px solid #404040; }
                    h6 { color: #a0a0a0; }
                    code { background-color: #2d2d2d; border: 1px solid #404040; }
                    pre { background-color: #2d2d2d; border: 1px solid #404040; }
                    a { color: #0A84FF; }
                    blockquote { color: #a0a0a0; border-left: 0.25em solid #505050; background-color: #252525; }
                    hr { background-color: #404040; }
                    table th, table td { border-color: #404040; }
                    table tr { border-top-color: #404040; background-color: #1e1e1e; }
                    table tr:nth-child(2n) { background-color: #2d2d2d; }
                    table th { background-color: #2d2d2d; }
                }
            """
            
        case .githubLight:
            return baseCSS + """
                body { background-color: #ffffff; color: #24292f; }
                h1, h2 { border-bottom: 1px solid #d0d7de; }
                h6 { color: #57606a; }
                code { background-color: rgba(175,184,193,0.2); }
                pre { background-color: #f6f8fa; }
                a { color: #0969da; }
                blockquote { color: #57606a; border-left: 0.25em solid #d0d7de; }
                hr { background-color: #d0d7de; }
                table th, table td { border-color: #d0d7de; }
                table tr { border-top-color: #d0d7de; background-color: #ffffff; }
                table tr:nth-child(2n) { background-color: #f6f8fa; }
                table th { background-color: #f6f8fa; }
            """
            
        case .githubDark:
            return baseCSS + """
                body { background-color: #0d1117; color: #c9d1d9; }
                h1, h2 { border-bottom: 1px solid #21262d; }
                h6 { color: #8b949e; }
                code { background-color: rgba(110,118,129,0.4); }
                pre { background-color: #161b22; }
                a { color: #58a6ff; }
                blockquote { color: #8b949e; border-left: 0.25em solid #3b434b; }
                hr { background-color: #21262d; }
                table th, table td { border-color: #21262d; }
                table tr { border-top-color: #21262d; background-color: #0d1117; }
                table tr:nth-child(2n) { background-color: #161b22; }
                table th { background-color: #161b22; }
            """
            
        case .light:
            return baseCSS + """
                body { background-color: #ffffff; color: #000000; }
                h1, h2 { border-bottom: 2px solid #000000; }
                h6 { color: #333333; }
                code { background-color: #f5f5f5; border: 1px solid #e0e0e0; }
                pre { background-color: #f9f9f9; border: 1px solid #e0e0e0; }
                a { color: #0000EE; }
                blockquote { color: #555555; border-left: 0.25em solid #cccccc; background-color: #fafafa; }
                hr { background-color: #000000; }
                table th, table td { border-color: #cccccc; }
                table tr { border-top-color: #cccccc; background-color: #ffffff; }
                table tr:nth-child(2n) { background-color: #f9f9f9; }
                table th { background-color: #f0f0f0; }
            """
            
        case .dark:
            return baseCSS + """
                body { background-color: #1e1e1e; color: #d4d4d4; }
                h1, h2 { border-bottom: 1px solid #404040; }
                h6 { color: #a0a0a0; }
                code { background-color: #2d2d2d; border: 1px solid #404040; }
                pre { background-color: #2d2d2d; border: 1px solid #404040; }
                a { color: #4fc3f7; }
                blockquote { color: #a0a0a0; border-left: 0.25em solid #505050; background-color: #252525; }
                hr { background-color: #404040; }
                table th, table td { border-color: #404040; }
                table tr { border-top-color: #404040; background-color: #1e1e1e; }
                table tr:nth-child(2n) { background-color: #2d2d2d; }
                table th { background-color: #2d2d2d; }
            """
        }
    }
    
    static func processInlineMarkdown(_ text: String) -> String {
        var result = text
        
        // Bold **text** or __text__
        result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__(.+?)__"#, with: "<strong>$1</strong>", options: .regularExpression)
        
        // Italic *text* or _text_
        result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"_(.+?)_"#, with: "<em>$1</em>", options: .regularExpression)
        
        // Inline code `code`
        result = result.replacingOccurrences(of: #"`(.+?)`"#, with: "<code>$1</code>", options: .regularExpression)
        
        // Links [text](url)
        result = result.replacingOccurrences(of: #"\[(.+?)\]\((.+?)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        
        return result
    }
    
    static func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    // Special HTML converter for PNG with proper styling
    static func convertToHTMLForPNG(_ markdown: String, theme: PreviewTheme) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var codeBlockContent = ""
        var codeLanguage = ""
        var inList = false
        var inTable = false
        var tableRows: [String] = []
        
        for i in 0..<lines.count {
            var line = lines[i]
            
            if line.hasPrefix("```") {
                if inTable { html += processTableForPNG(tableRows, theme: theme); tableRows = []; inTable = false }
                if inCodeBlock {
                    html += "<pre style='background-color: \(theme == .dark || theme == .githubDark ? "#2d2d2d" : "#f6f8fa"); border: 2px solid \(theme == .dark || theme == .githubDark ? "#404040" : "#d0d7de"); border-radius: 8px; padding: 16px; margin: 16px 0; font-family: \"SF Mono\", Monaco, monospace; font-size: 14px; line-height: 1.5; overflow-x: auto;'><code>\(escapeHTML(codeBlockContent))</code></pre>"
                    codeBlockContent = ""
                    codeLanguage = ""
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                    codeLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockContent += line + "\n"
                continue
            }
            
            if line.contains("|") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !inTable {
                    inTable = true
                }
                tableRows.append(line)
                continue
            } else {
                if inTable {
                    html += processTableForPNG(tableRows, theme: theme)
                    tableRows = []
                    inTable = false
                }
            }
            
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if inList { html += "</ul>"; inList = false }
                html += "<p style='margin: 8px 0;'></p>"
                continue
            }
            
            if line.hasPrefix("# ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<h1 style='font-size: 32px; font-weight: 700; margin: 24px 0 16px 0; padding-bottom: 8px; border-bottom: 3px solid \(theme == .dark || theme == .githubDark ? "#404040" : "#d0d7de"); color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</h1>"
            } else if line.hasPrefix("## ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(3))
                html += "<h2 style='font-size: 26px; font-weight: 700; margin: 20px 0 12px 0; padding-bottom: 6px; border-bottom: 2px solid \(theme == .dark || theme == .githubDark ? "#404040" : "#d0d7de"); color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</h2>"
            } else if line.hasPrefix("### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(4))
                html += "<h3 style='font-size: 22px; font-weight: 600; margin: 18px 0 10px 0; color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</h3>"
            } else if line.hasPrefix("#### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(5))
                html += "<h4 style='font-size: 18px; font-weight: 600; margin: 16px 0 8px 0; color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</h4>"
            } else if line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___") {
                if inList { html += "</ul>"; inList = false }
                html += "<hr style='border: 0; border-top: 3px solid \(theme == .dark || theme == .githubDark ? "#404040" : "#d0d7de"); margin: 24px 0;'>"
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                if !inList {
                    html += "<ul style='margin: 12px 0; padding-left: 32px; list-style-type: disc;'>"
                    inList = true
                }
                line = String(line.dropFirst(2))
                html += "<li style='margin: 6px 0; line-height: 1.6; color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</li>"
            } else if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                if !inList {
                    html += "<ol style='margin: 12px 0; padding-left: 32px;'>"
                    inList = true
                }
                if let match = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                    line = String(line[match.upperBound...])
                }
                html += "<li style='margin: 6px 0; line-height: 1.6; color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f");'>\(processInlineMarkdown(line))</li>"
            } else if line.hasPrefix("> ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<blockquote style='border-left: 4px solid \(theme == .dark || theme == .githubDark ? "#505050" : "#d0d7de"); padding: 8px 16px; margin: 12px 0; background-color: \(theme == .dark || theme == .githubDark ? "#252525" : "#f6f8fa"); color: \(theme == .dark || theme == .githubDark ? "#a0a0a0" : "#57606a"); border-radius: 4px;'>\(processInlineMarkdown(line))</blockquote>"
            } else {
                if inList { html += "</ul>"; inList = false }
                html += "<p style='margin: 10px 0; line-height: 1.7; color: \(theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f"); font-size: 16px;'>\(processInlineMarkdown(line))</p>"
            }
        }
        
        if inList { html += "</ul>" }
        if inTable { html += processTableForPNG(tableRows, theme: theme) }
        
        let bgColor = theme == .dark || theme == .githubDark ? "#1e1e1e" : "#ffffff"
        let textColor = theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f"
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style='font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; font-size: 16px; line-height: 1.6; color: \(textColor); background-color: \(bgColor); padding: 60px; margin: 0; max-width: 1080px;'>
            \(html)
        </body>
        </html>
        """
    }
    
    static func processTableForPNG(_ rows: [String], theme: PreviewTheme) -> String {
        guard !rows.isEmpty else { return "" }
        
        let borderColor = theme == .dark || theme == .githubDark ? "#404040" : "#d0d7de"
        let headerBg = theme == .dark || theme == .githubDark ? "#2d2d2d" : "#f6f8fa"
        let rowBg = theme == .dark || theme == .githubDark ? "#1e1e1e" : "#ffffff"
        let altRowBg = theme == .dark || theme == .githubDark ? "#252525" : "#f6f8fa"
        let textColor = theme == .dark || theme == .githubDark ? "#d4d4d4" : "#24292f"
        
        var html = "<table style='border-collapse: collapse; width: 100%; margin: 20px 0; border: 2px solid \(borderColor); border-radius: 8px; overflow: hidden;'>"
        var isHeader = true
        var rowIndex = 0
        
        for row in rows {
            let trimmed = row.trimmingCharacters(in: .whitespaces)
            let isSeparator = trimmed.replacingOccurrences(of: "|", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ":", with: "")
                .isEmpty
            
            if isSeparator {
                isHeader = false
                continue
            }
            
            let cells = row.split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if cells.isEmpty { continue }
            
            if isHeader {
                html += "<thead><tr>"
                for cell in cells {
                    html += "<th style='border: 1px solid \(borderColor); padding: 12px 16px; background-color: \(headerBg); font-weight: 700; text-align: left; color: \(textColor); font-size: 15px;'>\(processInlineMarkdown(cell))</th>"
                }
                html += "</tr></thead><tbody>"
                isHeader = false
            } else {
                let bg = rowIndex % 2 == 0 ? rowBg : altRowBg
                html += "<tr style='background-color: \(bg);'>"
                for cell in cells {
                    html += "<td style='border: 1px solid \(borderColor); padding: 10px 16px; color: \(textColor); font-size: 15px;'>\(processInlineMarkdown(cell))</td>"
                }
                html += "</tr>"
                rowIndex += 1
            }
        }
        
        html += "</tbody></table>"
        return html
    }
    
    // Special HTML converter for PDF with inline styles
    static func convertToHTMLForPDF(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var codeBlockContent = ""
        var inList = false
        var inTable = false
        var tableRows: [String] = []
        
        for i in 0..<lines.count {
            var line = lines[i]
            
            if line.hasPrefix("```") {
                if inTable { html += processTableForPDF(tableRows); tableRows = []; inTable = false }
                if inCodeBlock {
                    html += "<div style='background-color: #f5f5f5; border: 1px solid #ddd; padding: 12px; margin: 10px 0; font-family: monospace; font-size: 13px;'>\(escapeHTML(codeBlockContent))</div>"
                    codeBlockContent = ""
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockContent += line + "\n"
                continue
            }
            
            if line.contains("|") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !inTable {
                    inTable = true
                }
                tableRows.append(line)
                continue
            } else {
                if inTable {
                    html += processTableForPDF(tableRows)
                    tableRows = []
                    inTable = false
                }
            }
            
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if inList { html += "</ul>"; inList = false }
                html += "<p></p>"
                continue
            }
            
            if line.hasPrefix("# ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<h1 style='font-size: 24px; font-weight: bold; margin: 20px 0 10px 0;'>\(processInlineMarkdown(line))</h1>"
            } else if line.hasPrefix("## ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(3))
                html += "<h2 style='font-size: 20px; font-weight: bold; margin: 18px 0 8px 0;'>\(processInlineMarkdown(line))</h2>"
            } else if line.hasPrefix("### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(4))
                html += "<h3 style='font-size: 18px; font-weight: bold; margin: 16px 0 8px 0;'>\(processInlineMarkdown(line))</h3>"
            } else if line.hasPrefix("#### ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(5))
                html += "<h4 style='font-size: 16px; font-weight: bold; margin: 14px 0 6px 0;'>\(processInlineMarkdown(line))</h4>"
            } else if line.hasPrefix("---") || line.hasPrefix("***") {
                if inList { html += "</ul>"; inList = false }
                html += "<hr style='border: 0; border-top: 2px solid #000; margin: 20px 0;'>"
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                if !inList {
                    html += "<ul style='margin: 10px 0; padding-left: 30px;'>"
                    inList = true
                }
                line = String(line.dropFirst(2))
                html += "<li style='margin: 5px 0;'>\(processInlineMarkdown(line))</li>"
            } else if line.hasPrefix("> ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<blockquote style='border-left: 4px solid #ccc; padding-left: 15px; margin: 10px 0; color: #666;'>\(processInlineMarkdown(line))</blockquote>"
            } else {
                if inList { html += "</ul>"; inList = false }
                html += "<p style='margin: 8px 0; line-height: 1.6;'>\(processInlineMarkdown(line))</p>"
            }
        }
        
        if inList { html += "</ul>" }
        if inTable { html += processTableForPDF(tableRows) }
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
        </head>
        <body style='font-family: -apple-system, sans-serif; font-size: 14px; line-height: 1.6; color: #000; padding: 20px;'>
            \(html)
        </body>
        </html>
        """
    }
    
    static func processTableForPDF(_ rows: [String]) -> String {
        guard !rows.isEmpty else { return "" }
        
        var html = "<table style='border-collapse: collapse; width: 100%; margin: 15px 0; border: 2px solid #000;'>"
        var isHeader = true
        
        for row in rows {
            let trimmed = row.trimmingCharacters(in: .whitespaces)
            let isSeparator = trimmed.replacingOccurrences(of: "|", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ":", with: "")
                .isEmpty
            
            if isSeparator {
                isHeader = false
                continue
            }
            
            let cells = row.split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if cells.isEmpty { continue }
            
            if isHeader {
                html += "<thead><tr>"
                for cell in cells {
                    html += "<th style='border: 1px solid #000; padding: 8px; background-color: #f0f0f0; font-weight: bold; text-align: left;'>\(processInlineMarkdown(cell))</th>"
                }
                html += "</tr></thead><tbody>"
                isHeader = false
            } else {
                html += "<tr>"
                for cell in cells {
                    html += "<td style='border: 1px solid #000; padding: 8px;'>\(processInlineMarkdown(cell))</td>"
                }
                html += "</tr>"
            }
        }
        
        html += "</tbody></table>"
        return html
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let markdownContent: String
    let theme: PreviewTheme
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = MarkdownConverter.convertToHTML(markdownContent, theme: theme)
        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct DefaultAppInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Set as Default App")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("To make MarkdownViewer your default app for .md files:")
                    .font(.headline)
                
                InstructionStep(number: "1", text: "Right-click any .md file")
                InstructionStep(number: "2", text: "Select 'Get Info' (⌘I)")
                InstructionStep(number: "3", text: "Under 'Open with:', choose MarkdownViewer")
                InstructionStep(number: "4", text: "Click 'Change All...' button")
                InstructionStep(number: "5", text: "Confirm the change")
                
                Text("✅ Done! All .md files will now open with MarkdownViewer")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 8)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            Button("Got it!") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(30)
        .frame(width: 500)
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct MarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownEditor
        
        init(_ parent: MarkdownEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

// PDF Export Coordinator with proper WebView loading
