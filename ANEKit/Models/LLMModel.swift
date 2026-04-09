import Foundation

public enum LLMModel: String, CaseIterable, Codable {
    case qwen_0_8b = "Qwen/Qwen2.5-0.5B-Instruct-GGUF"
    case qwen_2b   = "Qwen/Qwen2.5-1.5B-Instruct-GGUF"
    case qwen_4b   = "Qwen/Qwen2.5-3B-Instruct-GGUF"

    public var displayName: String {
        switch self {
        case .qwen_0_8b: return "Qwen 0.8B (Fast, ~535 MB)"
        case .qwen_2b:   return "Qwen 2B (Balanced, ~1.3 GB)"
        case .qwen_4b:   return "Qwen 4B (Quality, ~2.8 GB)"
        }
    }

    public var approximateSize: String {
        switch self {
        case .qwen_0_8b: return "~535 MB"
        case .qwen_2b:   return "~1.3 GB"
        case .qwen_4b:   return "~2.8 GB"
        }
    }
}
