import AppKit

/// Struct representing a keyboard shortcut combination.
public struct KeyCombo {
    public let keyCode: UInt16
    public let modifiers: NSEvent.ModifierFlags

    public init(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// Common key codes for convenience
    public enum Keys {
        public static let v: UInt16     = 9
        public static let space: UInt16 = 49
        public static let c: UInt16     = 8
        public static let x: UInt16     = 7
    }
}

public class HotkeyManager {
    private var monitor: Any?
    private let combo: KeyCombo
    private let handler: () -> Void

    public init(combo: KeyCombo, handler: @escaping () -> Void) {
        self.combo = combo
        self.handler = handler
    }

    public func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return }
            let pressed = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if event.keyCode == self.combo.keyCode && pressed == self.combo.modifiers {
                DispatchQueue.main.async { self.handler() }
            }
        }
    }

    public func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    deinit { stop() }
}
