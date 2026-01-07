// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
use webbrowser;
// use tauri::menu::MenuBuilder;

#[tauri::command]
fn open_browser(address: &str) {
    webbrowser::open(address).expect("Failed to open defualt browser.");
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![open_browser])
        .setup(|app| {
            // TODO: Redo menu bar to return to home screen
            /**
            let menu = MenuBuilder::new(app)
                .text("open", "Open")
                .text("close", "Close")
                .check("check_item", "Check Item")
                .separator()
                .text("disabled_item", "Disabled Item")
                .text("status", "Status: Processing...")
                .build()?;

            app.set_menu(menu.clone())?;
            **/
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
