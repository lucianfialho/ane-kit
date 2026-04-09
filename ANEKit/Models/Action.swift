import Foundation

public struct Action: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var prompt: String   // use {input} as placeholder for captured text
    public var icon: String     // SF Symbol name

    public init(_ name: String, prompt: String, icon: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.prompt = prompt
        self.icon = icon
    }

    /// Replaces all occurrences of {input} in the prompt with the provided text.
    public func apply(to input: String) -> String {
        prompt.replacingOccurrences(of: "{input}", with: input)
    }
}
