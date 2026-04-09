import XCTest
@testable import MyApp

final class ClipboardMonitorTests: XCTestCase {

    func test_monitor_starts_stopped() {
        let monitor = ClipboardMonitor()
        XCTAssertFalse(monitor.isRunning)
    }

    func test_monitor_running_after_start() {
        let monitor = ClipboardMonitor()
        monitor.start()
        XCTAssertTrue(monitor.isRunning)
        monitor.stop()
    }

    func test_monitor_stopped_after_stop() {
        let monitor = ClipboardMonitor()
        monitor.start()
        monitor.stop()
        XCTAssertFalse(monitor.isRunning)
    }

    func test_monitor_detects_clipboard_change() {
        let monitor = ClipboardMonitor()
        let expectation = expectation(description: "clipboard change detected")
        let testText = "ane-app-test-\(UUID().uuidString)"

        monitor.onTextCopied = { text in
            if text == testText {
                expectation.fulfill()
            }
        }

        monitor.start()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(testText, forType: .string)

        waitForExpectations(timeout: 2.0)
        monitor.stop()
    }
}
