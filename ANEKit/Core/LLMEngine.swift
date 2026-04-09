import Foundation
import LLM

public enum LLMError: Error, LocalizedError {
    case notLoaded
    case stillLoading
    case downloadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notLoaded:              return "Model not loaded. Call load() first."
        case .stillLoading:           return "Model is downloading, please wait…"
        case .downloadFailed(let e):  return "Download failed: \(e)"
        }
    }
}

@MainActor
public class LLMEngine: ObservableObject {
    @Published public var isLoading = false
    @Published public var isReady = false
    @Published public var downloadProgress: Double = 0

    private var llm: LLM?
    private let model: LLMModel

    public init(model: LLMModel) {
        self.model = model
    }

    /// Downloads (if needed) and loads the model into memory.
    /// Models are cached by LLM.swift in ~/Documents.
    public func load() async throws {
        guard !isLoading && !isReady else { return }
        isLoading = true
        defer { isLoading = false }

        let huggingFaceModel = HuggingFaceModel(model.rawValue, .Q4_K_M, template: .chatML())
        let maxAttempts = 5

        for attempt in 1...maxAttempts {
            do {
                llm = try await LLM(from: huggingFaceModel) { [weak self] progress in
                    Task { @MainActor in self?.downloadProgress = progress }
                }
                isReady = llm != nil
                print("[LLMEngine] Model loaded: \(isReady)")
                return
            } catch {
                print("[LLMEngine] Attempt \(attempt)/\(maxAttempts) failed: \(error)")
                if attempt < maxAttempts {
                    let delay = Double(attempt * attempt) * 5.0  // 5s, 20s, 45s, 80s
                    print("[LLMEngine] Retrying in \(Int(delay))s…")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    throw LLMError.downloadFailed(error.localizedDescription)
                }
            }
        }
    }

    /// Runs inference. Must call load() first.
    public func run(prompt: String) async throws -> String {
        if isLoading { throw LLMError.stillLoading }
        guard let llm else { throw LLMError.notLoaded }
        return await llm.getCompletion(from: prompt)
    }
}
