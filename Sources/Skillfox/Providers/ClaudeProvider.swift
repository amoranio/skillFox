enum ClaudeProvider {
    static let definition = ProviderDefinition(
        id: "claude",
        name: "Claude",
        iconResourceName: "ProviderIcon-claude",
        tintHex: "#D97757",
        skillDirectories: [
            "~/.claude/skills",
        ]
    )
}
