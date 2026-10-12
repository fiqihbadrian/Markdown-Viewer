use std::fs;
use std::path::{Path, PathBuf};

use serde::Serialize;
use tauri::{AppHandle, Emitter, Manager};
use tauri_plugin_dialog::DialogExt;

#[derive(Serialize, Clone)]
struct LoadedFile {
    path: String,
    name: String,
    content: String,
}

fn is_markdown(path: &Path) -> bool {
    matches!(
        path.extension().and_then(|e| e.to_str()).map(|e| e.to_ascii_lowercase()),
        Some(ref e) if e == "md" || e == "markdown"
    )
}

// Ambil argumen pertama yang berupa file markdown (dari "Open with" atau CLI)
fn file_from_args(args: &[String]) -> Option<PathBuf> {
    args.iter()
        .skip(1)
        .map(PathBuf::from)
        .find(|p| p.is_file() && is_markdown(p))
}

fn read_into_event(path: &Path) -> Result<LoadedFile, String> {
    let content = fs::read_to_string(path).map_err(|e| format!("Gagal membaca file: {e}"))?;
    Ok(LoadedFile {
        path: path.to_string_lossy().into_owned(),
        name: path
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_default(),
        content,
    })
}

fn show_file(app: &AppHandle, path: &Path) {
    match read_into_event(path) {
        Ok(file) => {
            let _ = app.emit("file:loaded", file);
        }
        Err(msg) => {
            let _ = app.emit("file:error", msg);
        }
    }
}

fn focus_main(app: &AppHandle) {
    if let Some(win) = app.get_webview_window("main") {
        let _ = win.unminimize();
        let _ = win.show();
        let _ = win.set_focus();
    }
}

#[tauri::command]
fn open_file_dialog(app: AppHandle) -> Result<Option<LoadedFile>, String> {
    let picked = app
        .dialog()
        .file()
        .add_filter("Markdown", &["md", "markdown"])
        .blocking_pick_file();
    match picked {
        None => Ok(None),
        Some(fp) => {
            let path = fp.into_path().map_err(|e| e.to_string())?;
            read_into_event(&path).map(Some)
        }
    }
}

#[tauri::command]
fn save_file(path: String, content: String) -> Result<(), String> {
    let p = PathBuf::from(&path);
    if !is_markdown(&p) {
        return Err("Hanya file .md atau .markdown yang bisa disimpan".into());
    }
    fs::write(&p, content).map_err(|e| format!("Gagal menyimpan: {e}"))
}

#[tauri::command]
fn save_png(app: AppHandle, default_name: String, data_base64: String) -> Result<Option<String>, String> {
    use base64::Engine;
    let bytes = base64::engine::general_purpose::STANDARD
        .decode(data_base64)
        .map_err(|e| e.to_string())?;
    let picked = app
        .dialog()
        .file()
        .set_file_name(&default_name)
        .add_filter("PNG", &["png"])
        .blocking_save_file();
    match picked {
        None => Ok(None),
        Some(fp) => {
            let path = fp.into_path().map_err(|e| e.to_string())?;
            fs::write(&path, bytes).map_err(|e| format!("Gagal menyimpan PNG: {e}"))?;
            Ok(Some(path.to_string_lossy().into_owned()))
        }
    }
}

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_single_instance::init(|app, args, _cwd| {
            focus_main(app);
            if let Some(path) = file_from_args(&args) {
                show_file(app, &path);
            }
        }))
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![open_file_dialog, save_file, save_png])
        .setup(|app| {
            let args: Vec<String> = std::env::args().collect();
            if let Some(path) = file_from_args(&args) {
                let handle = app.handle().clone();
                // Tunggu frontend siap sebelum mengirim event
                std::thread::spawn(move || {
                    std::thread::sleep(std::time::Duration::from_millis(600));
                    show_file(&handle, &path);
                });
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("gagal menjalankan MarkdownViewer");
}
