import Foundation
import LLM

public enum LLMError: Error, LocalizedError {
    case notLoaded

    public var errorDescription: String? {
        switch self {
        case .notLoaded: return "Model not loaded. Call load() first."
        }
    }
}

@MainActor
public class LLMEngine: ObservableObject {
    @Published public var isLoading = false
    @Published public var isReady = false

    private var llm: LLM?
    private let model: LLMModel

    public init(model: LLMModel) {
        self.model = model
    }

    /// Downloads (if needed) and loads the model into memory.
    /// Models are cached by LLM.swift in ~/Documents.
    public func load() async throws {
        isLoading = true
        defer { isLoading = false }
        let huggingFaceModel = HuggingFaceModel(model.rawValue, .Q4_K_M, template: .chatML())
        llm = try await LLM(from: huggingFaceModel)
        isReady = llm != nil
    }

    /// Runs inference. Must call load() first.
    public func run(prompt: String) async throws -> String {
        guard let llm else { throw LLMError.notLoaded }
        return await llm.getCompletion(from: prompt)
    }
}
