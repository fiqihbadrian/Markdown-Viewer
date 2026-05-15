import SwiftUI
import UniformTypeIdentifiers

@main
struct MarkdownViewerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Markdown File...") {
                    openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(after: .appSettings) {
                Button("Set as Default App for .md Files") {
                    setAsDefaultApp()
                }
            }
        }
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "md")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            NotificationCenter.default.post(name: .openMarkdownFile, object: url)
        }
    }
    
    func setAsDefaultApp() {
        let alert = NSAlert()
        alert.messageText = "Set as Default App for Markdown Files"
        alert.informativeText = "To set MarkdownViewer as the default app for .md files:\n\n1. Right-click any .md file\n2. Select 'Get Info' (⌘I)\n3. Under 'Open with:', choose MarkdownViewer\n4. Click 'Change All...'\n\nThis will apply to all .md files."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Show .md File in Finder")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open Finder to show a sample .md file for easy access
            if let testFile = findMarkdownFile() {
                NSWorkspace.shared.activateFileViewerSelecting([testFile])
            } else {
                // If no .md file found, show alert
                let noFileAlert = NSAlert()
                noFileAlert.messageText = "No Markdown File Found"
                noFileAlert.informativeText = "No .md file found in common locations (Documents, Desktop, Home).\n\nYou can:\n1. Create a test .md file\n2. Or right-click any existing .md file and follow the steps above."
                noFileAlert.alertStyle = .informational
                noFileAlert.addButton(withTitle: "OK")
                noFileAlert.runModal()
            }
        }
    }
    
    func findMarkdownFile() -> URL? {
        // Try to find any .md file in common locations
        let searchPaths: [URL?] = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first,
            URL(fileURLWithPath: NSHomeDirectory())
        ]
        
        for basePath in searchPaths.compactMap({ $0 }) {
            if let enumerator = FileManager.default.enumerator(at: basePath, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension.lowercased() == "md" {
                        return fileURL
                    }
                }
            }
        }
        return nil
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            NotificationCenter.default.post(name: .openMarkdownFile, object: url)
        }
    }
}

extension Notification.Name {
    static let openMarkdownFile = Notification.Name("openMarkdownFile")
}
