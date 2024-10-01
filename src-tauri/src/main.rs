// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
use std::process::Command;
use webbrowser;

#[tauri::command]
fn ping_address(address: &str) -> bool {
    let ping = Command::new("ping")
        .arg("-i")
        .arg("1")
        .arg(address)
        .output()
        .expect("");

    if ping.status.success() {
        return true;
    }

    return false;
}

#[tauri::command]
fn open_browser(address: &str) {
    if ping_address(address) {
        webbrowser::open(address).expect("Failed to open defualt browser.");
    }
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![open_browser, ping_address])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
