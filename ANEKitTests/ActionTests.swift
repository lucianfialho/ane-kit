import XCTest
@testable import MyApp

final class ActionTests: XCTestCase {

    func test_action_apply_replaces_input_placeholder() {
        let action = Action("Test", prompt: "Translate: {input}", icon: "globe")
        let result = action.apply(to: "hello world")
        XCTAssertEqual(result, "Translate: hello world")
    }

    func test_action_apply_with_no_placeholder_returns_prompt() {
        let action = Action("Test", prompt: "Just translate", icon: "globe")
        let result = action.apply(to: "hello")
        XCTAssertEqual(result, "Just translate")
    }

    func test_action_apply_replaces_multiple_occurrences() {
        let action = Action("Test", prompt: "{input} — {input}", icon: "doc")
        let result = action.apply(to: "hello")
        XCTAssertEqual(result, "hello — hello")
    }

    func test_action_has_stable_id() {
        let id = UUID()
        let action = Action("Test", prompt: "p", icon: "i", id: id)
        XCTAssertEqual(action.id, id)
    }

    func test_llm_model_display_names_are_non_empty() {
        for model in LLMModel.allCases {
            XCTAssertFalse(model.displayName.isEmpty)
            XCTAssertFalse(model.approximateSize.isEmpty)
        }
    }
}
