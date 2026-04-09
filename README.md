# ANEKit

A template for building macOS menu bar apps powered by **Apple Intelligence** — no API key, no model download, runs entirely on-device via the Apple Neural Engine.

> Think of it as Next.js for macOS AI apps: handles all the boilerplate, you ship the idea.

Inspired by [Ghost Pepper](https://github.com/matthartman/ghost-pepper).

---

## What you get

- Menu bar icon with status states
- Apple Intelligence inference via the [`FoundationModels`](https://developer.apple.com/documentation/foundationmodels) framework
- Global hotkey or clipboard trigger
- Floating popup near cursor with action picker
- Result view with one-click copy to clipboard
- Settings window with full action CRUD

## Requirements

- **macOS 26** (Tahoe) or later
- **Apple Silicon** with Apple Intelligence enabled
- Xcode 26+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Getting started

```bash
# 1. Use this template on GitHub, then clone your repo
git clone https://github.com/your-username/your-app-name
cd your-app-name

# 2. Generate the Xcode project
xcodegen generate

# 3. Open in Xcode
open MyApp.xcodeproj
```

4. Set your **Team** in Xcode → Signing & Capabilities (or set `DEVELOPMENT_TEAM` in `project.yml`)
5. Edit **`MyApp/AppConfig.swift`** — the only file you need to touch
6. `Cmd+R` to run

## AppConfig.swift

```swift
struct AppConfig: ANEAppConfig {
    static let appName = "My App"
    static let trigger = Trigger.hotkey  // .clipboard | .hotkey

    static let actions: [Action] = [
        Action("Format JSON",     prompt: "Format as pretty JSON. Return only the JSON:\n\n{input}",              icon: "curlybraces"),
        Action("Translate EN→PT", prompt: "Translate to Brazilian Portuguese. Return only the translation:\n\n{input}", icon: "globe"),
        Action("Summarize",       prompt: "Summarize in 2 bullet points:\n\n{input}",                             icon: "text.quote"),
        Action("Fix Grammar",     prompt: "Fix grammar and spelling. Return only the corrected text:\n\n{input}", icon: "checkmark.seal"),
    ]
}
```

`{input}` is replaced with the captured text at runtime.

## Triggers

| Trigger | Behavior |
|---|---|
| `.hotkey` | Press `Cmd+Shift+V` — uses current clipboard content |
| `.clipboard` | Popup appears automatically whenever you copy text |

## Project structure

```
ane-kit/
  ANEKit/                     framework — don't edit
    Core/
      LLMEngine.swift         Apple Intelligence session management
      MenuBarManager.swift    status bar icon and menu
      HotkeyManager.swift     global hotkey listener
      ClipboardMonitor.swift  clipboard polling
    UI/
      PopupPanel.swift        floating NSPanel near cursor
      ActionPickerView.swift  action list
      ResultView.swift        result + copy button
      SettingsView.swift      action CRUD
    Models/
      Action.swift            Action model + {input} substitution
      Trigger.swift           trigger enum
      ANEAppConfig.swift      protocol your AppConfig must conform to
  MyApp/                      your app — edit here
    AppConfig.swift           ← the only file you need to touch
    MyAppApp.swift            @main entry point + AppDelegate
  ANEKitTests/                unit tests
```

## How it works

ANEKit uses Apple's [`FoundationModels`](https://developer.apple.com/documentation/foundationmodels) framework, which provides access to the on-device language model powering Apple Intelligence. There is no internet request, no API key, and no model to download — the model ships with macOS 26.

Each action creates a fresh `LanguageModelSession` with a concise system prompt, runs inference, and returns the result as plain text.

## License

MIT
