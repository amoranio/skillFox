enum CopilotProvider {
    static let definition = ProviderDefinition(
        id: "copilot",
        name: "Copilot",
        iconResourceName: "ProviderIcon-copilot",
        tintHex: "#6A4CF6",
        skillDirectories: [
            "~/.copilot/skills",
            "~/.config/github-copilot/skills",
        ]
    )
}
