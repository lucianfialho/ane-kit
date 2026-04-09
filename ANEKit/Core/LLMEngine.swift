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

    private var modelsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ANEKit/Models", isDirectory: true)
    }

    private var modelPath: URL {
        modelsDirectory.appendingPathComponent(model.fileName)
    }

    public init(model: LLMModel) {
        self.model = model
    }

    /// Downloads (if needed) and loads the model from a direct HuggingFace URL.
    /// Uses URLSession directly — no API rate limits (same approach as Ghost Pepper).
    public func load() async throws {
        guard !isLoading && !isReady else { return }
        isLoading = true
        defer { isLoading = false }

        try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)

        if !FileManager.default.fileExists(atPath: modelPath.path) {
            do {
                try await downloadModel()
            } catch {
                print("[LLMEngine] Download failed: \(error)")
                throw LLMError.downloadFailed(error.localizedDescription)
            }
        }

        print("[LLMEngine] Loading model from disk…")
        let loadedLLM = await Task.detached { [modelPath] () -> LLM? in
            LLM(from: modelPath, template: .chatML())
        }.value

        guard let loadedLLM else {
            throw LLMError.downloadFailed("Failed to initialize model from file.")
        }
        llm = loadedLLM
        isReady = true
        print("[LLMEngine] Model ready.")
    }

    /// Runs inference. Must call load() first.
    public func run(prompt: String) async throws -> String {
        if isLoading { throw LLMError.stillLoading }
        guard let llm else { throw LLMError.notLoaded }
        return await llm.getCompletion(from: prompt)
    }

    // MARK: - Private

    private func downloadModel() async throws {
        print("[LLMEngine] ⬇️ Starting download: \(model.fileName) (~\(model.approximateSize))")
        print("[LLMEngine] URL: \(model.downloadURL)")
        downloadProgress = 0

        var request = URLRequest(url: model.downloadURL)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        // Stream bytes to track progress
        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw LLMError.downloadFailed("No HTTP response")
        }
        print("[LLMEngine] HTTP \(http.statusCode)")
        guard http.statusCode == 200 else {
            throw LLMError.downloadFailed("HTTP \(http.statusCode)")
        }

        let totalBytes = http.expectedContentLength
        var receivedBytes: Int64 = 0
        var lastLoggedPct = -10

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(model.fileName)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: tempURL)

        for try await byte in asyncBytes {
            handle.write(Data([byte]))
            receivedBytes += 1
            if totalBytes > 0 {
                let pct = Int(Double(receivedBytes) / Double(totalBytes) * 100)
                if pct >= lastLoggedPct + 10 {
                    print("[LLMEngine] ⬇️ \(pct)% (\(receivedBytes / 1_048_576)MB / \(totalBytes / 1_048_576)MB)")
                    lastLoggedPct = pct
                    await MainActor.run { downloadProgress = Double(pct) / 100 }
                }
            }
        }
        handle.closeFile()

        if FileManager.default.fileExists(atPath: modelPath.path) {
            try FileManager.default.removeItem(at: modelPath)
        }
        try FileManager.default.moveItem(at: tempURL, to: modelPath)
        downloadProgress = 1.0
        print("[LLMEngine] ✅ Download complete: \(model.fileName)")
    }
}
