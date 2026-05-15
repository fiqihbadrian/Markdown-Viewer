import SwiftUI
import WebKit

struct ContentView: View {
    @State private var markdownContent: String = "# Welcome to Markdown Viewer\n\nDouble-click any `.md` file to open it here.\n\nOr use **⌘O** to open a file.\n\n---\n\n## Set as Default App\n\nTo make MarkdownViewer your default app for .md files:\n\n1. Go to menu: **MarkdownViewer → Set as Default App for .md Files**\n2. Or right-click any .md file → Get Info (⌘I)\n3. Under 'Open with:', choose MarkdownViewer\n4. Click 'Change All...'"
    @State private var currentFileURL: URL?
    @State private var showingDefaultAppInfo = false
    
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
                    Button(action: reloadFile) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Reload file")
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
            
            // Markdown preview
            MarkdownWebView(markdownContent: markdownContent)
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
    }
    
    func loadMarkdownFile(url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            markdownContent = content
            currentFileURL = url
        } catch {
            markdownContent = "# Error\n\nCould not load file: \(error.localizedDescription)"
        }
    }
    
    func reloadFile() {
        if let url = currentFileURL {
            loadMarkdownFile(url: url)
        }
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let markdownContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = convertMarkdownToHTML(markdownContent)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func convertMarkdownToHTML(_ markdown: String) -> String {
        var lines = markdown.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var codeBlockContent = ""
        var inList = false
        
        for i in 0..<lines.count {
            var line = lines[i]
            
            // Code blocks (```)
            if line.hasPrefix("```") {
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
            
            // Empty lines
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if inList {
                    html += "</ul>"
                    inList = false
                }
                html += "<p></p>"
                continue
            }
            
            // Headers
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
            // Horizontal rule
            else if line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___") {
                if inList { html += "</ul>"; inList = false }
                html += "<hr>"
            }
            // Lists
            else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                if !inList {
                    html += "<ul>"
                    inList = true
                }
                line = String(line.dropFirst(2))
                html += "<li>\(processInlineMarkdown(line))</li>"
            }
            // Numbered lists
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
            // Blockquote
            else if line.hasPrefix("> ") {
                if inList { html += "</ul>"; inList = false }
                line = String(line.dropFirst(2))
                html += "<blockquote>\(processInlineMarkdown(line))</blockquote>"
            }
            // Regular paragraph
            else {
                if inList { html += "</ul>"; inList = false }
                html += "<p>\(processInlineMarkdown(line))</p>"
            }
        }
        
        if inList {
            html += "</ul>"
        }
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                    line-height: 1.6;
                    padding: 30px;
                    max-width: 980px;
                    margin: 0 auto;
                    color: #24292f;
                    font-size: 16px;
                }
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                    line-height: 1.25;
                }
                h1 { 
                    font-size: 2em; 
                    border-bottom: 1px solid #d0d7de; 
                    padding-bottom: 0.3em;
                    margin-top: 0;
                }
                h2 { 
                    font-size: 1.5em; 
                    border-bottom: 1px solid #d0d7de; 
                    padding-bottom: 0.3em;
                }
                h3 { font-size: 1.25em; }
                h4 { font-size: 1em; }
                h5 { font-size: 0.875em; }
                h6 { font-size: 0.85em; color: #57606a; }
                
                p {
                    margin-top: 0;
                    margin-bottom: 16px;
                }
                
                code {
                    background-color: rgba(175,184,193,0.2);
                    padding: 0.2em 0.4em;
                    border-radius: 6px;
                    font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
                    font-size: 85%;
                }
                
                pre {
                    background-color: #f6f8fa;
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
                
                a { 
                    color: #0969da; 
                    text-decoration: none; 
                }
                a:hover { 
                    text-decoration: underline; 
                }
                
                ul, ol {
                    margin-top: 0;
                    margin-bottom: 16px;
                    padding-left: 2em;
                }
                
                li {
                    margin-top: 0.25em;
                }
                
                li + li {
                    margin-top: 0.25em;
                }
                
                blockquote {
                    margin: 0 0 16px 0;
                    padding: 0 1em;
                    color: #57606a;
                    border-left: 0.25em solid #d0d7de;
                }
                
                hr {
                    height: 0.25em;
                    padding: 0;
                    margin: 24px 0;
                    background-color: #d0d7de;
                    border: 0;
                }
                
                strong {
                    font-weight: 600;
                }
                
                em {
                    font-style: italic;
                }
                
                @media (prefers-color-scheme: dark) {
                    body { 
                        background-color: #0d1117; 
                        color: #c9d1d9; 
                    }
                    h1, h2 { 
                        border-bottom-color: #21262d; 
                    }
                    h6 {
                        color: #8b949e;
                    }
                    code { 
                        background-color: rgba(110,118,129,0.4); 
                    }
                    pre {
                        background-color: #161b22;
                    }
                    a { 
                        color: #58a6ff; 
                    }
                    blockquote {
                        color: #8b949e;
                        border-left-color: #3b434b;
                    }
                    hr {
                        background-color: #21262d;
                    }
                }
            </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
    
    func processInlineMarkdown(_ text: String) -> String {
        var result = escapeHTML(text)
        
        // Bold **text** or __text__
        result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__(.+?)__"#, with: "<strong>$1</strong>", options: .regularExpression)
        
        // Italic *text* or _text_
        result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"(?<!_)_([^_]+?)_(?!_)"#, with: "<em>$1</em>", options: .regularExpression)
        
        // Inline code `code`
        result = result.replacingOccurrences(of: #"`(.+?)`"#, with: "<code>$1</code>", options: .regularExpression)
        
        // Links [text](url)
        result = result.replacingOccurrences(of: #"\[(.+?)\]\((.+?)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        
        // Strikethrough ~~text~~
        result = result.replacingOccurrences(of: #"~~(.+?)~~"#, with: "<del>$1</del>", options: .regularExpression)
        
        return result
    }
    
    func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

// Info view for setting default app
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
