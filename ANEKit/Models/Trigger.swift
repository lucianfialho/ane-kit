import Foundation

public enum Trigger: String, CaseIterable, Codable {
    case clipboard   // polls NSPasteboard.general.changeCount
    case hotkey      // global key combo opens popup
    case selection   // reads selected text via Accessibility API
}
