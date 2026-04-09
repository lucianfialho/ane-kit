import AppKit

public class ClipboardMonitor: ObservableObject {
    @Published public var lastText: String = ""
    public var onTextCopied: ((String) -> Void)?
    public private(set) var isRunning = false

    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func poll() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            self?.lastText = text
            self?.onTextCopied?(text)
        }
    }
}
