// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
use webbrowser;

#[tauri::command]
fn open_browser(address: &str) {
    webbrowser::open(address).expect("Failed to open defualt browser.");
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![open_browser])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
