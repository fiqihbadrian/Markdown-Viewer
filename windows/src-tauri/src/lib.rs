use std::fs;
use std::path::{Path, PathBuf};
use std::sync::Mutex;

use serde::Serialize;
use tauri::{AppHandle, Emitter, Manager, State};
use tauri_plugin_dialog::DialogExt;

#[derive(Serialize, Clone)]
struct LoadedFile {
    path: String,
    name: String,
    content: String,
}

/// File yang diminta lewat CLI / "Open with" / second instance, disimpan sampai
/// frontend siap mengambilnya. Menghindari balapan dengan event yang bisa hilang.
#[derive(Default)]
struct PendingFile(Mutex<Option<LoadedFile>>);

fn is_markdown(path: &Path) -> bool {
    matches!(
        path.extension().and_then(|e| e.to_str()).map(|e| e.to_ascii_lowercase()),
        Some(ref e) if e == "md" || e == "markdown"
    )
}

fn hex_value(byte: u8) -> Option<u8> {
    match byte {
        b'0'..=b'9' => Some(byte - b'0'),
        b'a'..=b'f' => Some(byte - b'a' + 10),
        b'A'..=b'F' => Some(byte - b'A' + 10),
        _ => None,
    }
}

fn percent_decode(input: &str) -> String {
    let bytes = input.as_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'%' && i + 2 < bytes.len() {
            if let (Some(hi), Some(lo)) = (hex_value(bytes[i + 1]), hex_value(bytes[i + 2])) {
                out.push(hi * 16 + lo);
                i += 3;
                continue;
            }
        }
        out.push(bytes[i]);
        i += 1;
    }
    String::from_utf8_lossy(&out).into_owned()
}

/// Normalisasi path dari argumen CLI. Beberapa desktop mengirim `file:///...`.
fn normalize_arg(arg: &str) -> Option<PathBuf> {
    let trimmed = arg.trim();
    if trimmed.is_empty() || trimmed.starts_with('-') {
        return None;
    }
    if let Some(rest) = trimmed.strip_prefix("file://") {
        // buang host kosong / "localhost"
        let rest = rest.strip_prefix("localhost").unwrap_or(rest);
        return Some(PathBuf::from(percent_decode(rest)));
    }
    Some(PathBuf::from(trimmed))
}

// Ambil argumen pertama yang berupa file markdown (dari "Open with" atau CLI)
fn file_from_args(args: &[String]) -> Option<PathBuf> {
    args.iter()
        .skip(1)
        .filter_map(|a| normalize_arg(a))
        .find(|p| p.is_file() && is_markdown(p))
}

fn read_into_event(path: &Path) -> Result<LoadedFile, String> {
    if !path.is_file() {
        return Err(format!("File tidak ditemukan: {}", path.display()));
    }
    // Baca byte lalu decode lossy supaya file non-UTF8 (mis. Latin-1) tetap tampil.
    let bytes = fs::read(path).map_err(|e| format!("Gagal membaca file: {e}"))?;
    let text = String::from_utf8_lossy(&bytes);
    let content = text.strip_prefix('\u{feff}').unwrap_or(&text).to_string();
    Ok(LoadedFile {
        path: path.to_string_lossy().into_owned(),
        name: path
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_default(),
        content,
    })
}

fn store_pending(app: &AppHandle, file: LoadedFile) {
    if let Some(state) = app.try_state::<PendingFile>() {
        *state.0.lock().unwrap() = Some(file);
    }
}

fn stash(app: &AppHandle, file: LoadedFile) {
    store_pending(app, file.clone());
    let _ = app.emit("file:loaded", file);
}

fn show_file(app: &AppHandle, path: &Path) {
    match read_into_event(path) {
        Ok(file) => stash(app, file),
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
fn open_path(path: String) -> Result<LoadedFile, String> {
    let p = normalize_arg(&path).ok_or_else(|| "Path tidak valid".to_string())?;
    if !p.is_file() {
        return Err(format!("File tidak ditemukan: {}", p.display()));
    }
    if !is_markdown(&p) {
        return Err("Hanya file .md atau .markdown yang bisa dibuka".into());
    }
    read_into_event(&p)
}

#[tauri::command]
fn take_pending_file(state: State<'_, PendingFile>) -> Option<LoadedFile> {
    state.0.lock().unwrap().take()
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
        .manage(PendingFile::default())
        .plugin(tauri_plugin_single_instance::init(|app, args, _cwd| {
            focus_main(app);
            if let Some(path) = file_from_args(&args) {
                show_file(app, &path);
            }
        }))
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![
            open_file_dialog,
            open_path,
            take_pending_file,
            save_file,
            save_png
        ])
        .setup(|app| {
            let args: Vec<String> = std::env::args().collect();
            if let Some(path) = file_from_args(&args) {
                if let Ok(file) = read_into_event(&path) {
                    // Frontend belum tentu siap; simpan dan biarkan ia mengambilnya.
                    store_pending(app.handle(), file);
                }
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("gagal menjalankan MarkdownViewer");
}
