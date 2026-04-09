import AppKit
import SwiftUI

public class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    public var onSettingsRequested: (() -> Void)?

    public override init() {
        super.init()
    }

    /// Call once at app launch. Installs the menu bar icon and dropdown menu.
    public func setup(appName: String, iconSymbol: String = "sparkles") {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: iconSymbol, accessibilityDescription: appName)

        let menu = NSMenu()
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        statusItem?.menu = menu
    }

    @objc private func openSettings() {
        onSettingsRequested?()
    }
}
