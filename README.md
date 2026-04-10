# SwiftAIKit

> Apple Intelligence in your macOS app. No API key. No model download. Just actions.

Adding AI to a macOS app used to mean picking a provider, managing API keys,
downloading models, worrying about privacy, and hoping the network holds up.
SwiftAIKit cuts all of that — it runs entirely on-device via the Apple Neural Engine,
and your entire integration is one file:

```swift
static let actions: [Action] = [
    Action("Fix Grammar", prompt: "Fix grammar. Return only corrected text:\n\n{input}", icon: "checkmark.seal"),
    Action("Summarize",   prompt: "Summarize in 2 bullets:\n\n{input}",                 icon: "text.quote"),
]
```

That's it. SwiftAIKit handles capture, inference, and result presentation.

---

## Features

- **Zero configuration** — define actions in one file, framework handles the rest
- **Fully on-device** — runs via Apple Neural Engine, no internet required
- **Privacy first** — text never leaves the device
- **Two trigger modes** — global hotkey or auto-popup on clipboard copy
- **Full action CRUD** — add, edit, remove actions at runtime via Settings
- **UI-agnostic framework** — `MyApp` is just a reference implementation; use SwiftAIKit in any macOS app

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
struct AppConfig: SwiftAIAppConfig {
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
swift-ai-kit/
  SwiftAIKit/                     framework — don't edit
    Core/
      LLMEngine.swift         FoundationModels session management
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
      SwiftAIAppConfig.swift      protocol your AppConfig must conform to
  MyApp/                      reference implementation — edit here
    AppConfig.swift           ← the only file you need to touch
    MyAppApp.swift            @main entry point + AppDelegate
  SwiftAIKitTests/                unit tests
```

## License

MIT
