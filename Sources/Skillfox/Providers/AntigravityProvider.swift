enum AntigravityProvider {
    static let definition = ProviderDefinition(
        id: "antigravity",
        name: "Antigravity",
        iconResourceName: "ProviderIcon-antigravity",
        tintHex: "#F59E0B",
        skillDirectories: [
            ".agent/skills",
            "~/.gemini/antigravity/skills",
        ]
    )
}
