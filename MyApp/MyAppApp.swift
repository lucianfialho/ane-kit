import AppKit
import SwiftUI

@main
struct MyAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBar = MenuBarManager()
    private let clipboard = ClipboardMonitor()
    private let llmEngine = LLMEngine(model: AppConfig.defaultModel)
    private var hotkey: HotkeyManager?
    private let panel = PopupPanel()
    private var settingsWindow: NSWindow?

    @AppStorage("customActions") private var actionsData: Data = {
        (try? JSONEncoder().encode(AppConfig.actions)) ?? Data()
    }()

    private var currentActions: [Action] {
        (try? JSONDecoder().decode([Action].self, from: actionsData)) ?? AppConfig.actions
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        menuBar.setup(appName: AppConfig.appName)
        menuBar.onSettingsRequested = { [weak self] in self?.openSettings() }

        switch AppConfig.trigger {
        case .clipboard:
            clipboard.onTextCopied = { [weak self] text in self?.showPicker(for: text) }
            clipboard.start()
        case .hotkey:
            let combo = AppConfig.hotkeyCombo
            hotkey = HotkeyManager(combo: combo) { [weak self] in
                if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
                    self?.showPicker(for: text)
                }
            }
            hotkey?.start()
        case .selection:
            let combo = AppConfig.hotkeyCombo
            hotkey = HotkeyManager(combo: combo) { [weak self] in
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
                        self?.showPicker(for: text)
                    }
                }
            }
            hotkey?.start()
        }

        Task { try? await llmEngine.load() }
    }

    private func showPicker(for text: String) {
        let preview = String(text.prefix(80)) + (text.count > 80 ? "…" : "")
        let pickerView = ActionPickerView(
            actions: currentActions,
            inputPreview: preview,
            onSelect: { [weak self] action in self?.runAction(action, on: text) },
            onDismiss: { [weak self] in self?.panel.dismiss() }
        )
        panel.setContent(pickerView)
        panel.showNearCursor()
    }

    private func runAction(_ action: Action, on text: String) {
        let prompt = action.apply(to: text)

        panel.setContent(ResultView(
            state: .loading,
            actionName: action.name,
            onCopy: { _ in },
            onBack: { [weak self] in self?.showPicker(for: text) }
        ))

        Task { @MainActor in
            do {
                let result = try await llmEngine.run(prompt: prompt)
                panel.setContent(ResultView(
                    state: .result(result),
                    actionName: action.name,
                    onCopy: { [weak self] output in
                        guard let self else { return }
                        // Pause monitor to prevent re-triggering on our own output
                        if AppConfig.trigger == .clipboard { self.clipboard.stop() }
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                        self.panel.dismiss()
                        // Resume after the clipboard change is past the polling window
                        if AppConfig.trigger == .clipboard {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.clipboard.start()
                            }
                        }
                    },
                    onBack: { [weak self] in self?.showPicker(for: text) }
                ))
            } catch {
                panel.setContent(ResultView(
                    state: .error(error.localizedDescription),
                    actionName: action.name,
                    onCopy: { _ in },
                    onBack: { [weak self] in self?.showPicker(for: text) }
                ))
            }
        }
    }

    private func openSettings() {
        let settingsView = SettingsView(initialActions: currentActions) { [weak self] updated in
            self?.actionsData = (try? JSONEncoder().encode(updated)) ?? Data()
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "\(AppConfig.appName) Settings"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }
}
