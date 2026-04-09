import XCTest
@testable import MyApp

final class LLMEngineTests: XCTestCase {

    func test_engine_starts_not_ready() {
        let engine = LLMEngine(model: .qwen_0_8b)
        XCTAssertFalse(engine.isReady)
        XCTAssertFalse(engine.isLoading)
    }

    func test_run_throws_when_not_loaded() async {
        let engine = LLMEngine(model: .qwen_0_8b)
        do {
            _ = try await engine.run(prompt: "hello")
            XCTFail("Expected LLMError.notLoaded")
        } catch LLMError.notLoaded {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
