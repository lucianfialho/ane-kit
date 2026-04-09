import Foundation

// ============================================================
//  AppConfig.swift — THE ONLY FILE YOU NEED TO EDIT
//  Rename MyApp → your app name everywhere, then configure below.
// ============================================================

struct AppConfig: ANEAppConfig {
    static let appName      = "My ANE App"
    static let bundleID     = "com.yourname.myapp"
    static let trigger      = Trigger.hotkey   // popup abre com Cmd+Shift+V
    static let defaultModel = LLMModel.qwen_0_8b

    static let actions: [Action] = [
        Action("Format JSON",     prompt: "Format the following as pretty-printed JSON. Return only the JSON, no explanation: {input}",    icon: "curlybraces"),
        Action("Translate EN→PT", prompt: "Translate the following text to Brazilian Portuguese. Return only the translation: {input}",    icon: "globe"),
        Action("Summarize",       prompt: "Summarize the following in 2 concise bullet points: {input}",                                  icon: "text.quote"),
        Action("Fix Grammar",     prompt: "Fix grammar and spelling in the following text. Return only the corrected text: {input}",       icon: "checkmark.seal"),
    ]
}
