enum OpenCodeProvider {
    static let definition = ProviderDefinition(
        id: "opencode",
        name: "OpenCode",
        iconResourceName: "ProviderIcon-opencode",
        tintHex: "#22C55E",
        skillDirectories: [
            ".opencode/skills",
            ".claude/skills",
            ".agents/skills",
            "~/.config/opencode/skills",
            "~/.claude/skills",
            "~/.agents/skills",
        ]
    )
}
