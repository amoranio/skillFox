enum GeminiProvider {
    static let definition = ProviderDefinition(
        id: "gemini",
        name: "Gemini",
        iconResourceName: "ProviderIcon-gemini",
        tintHex: "#3B82F6",
        skillDirectories: [
            ".gemini/skills",
            "~/.gemini/skills",
            ".gemini/extensions",
            "~/.gemini/extensions",
        ]
    )
}
