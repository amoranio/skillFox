import Foundation

struct SkillDescriptor: Identifiable, Hashable {
    let displayPath: String
    let snippet: String?
    let sourceFileURL: URL?

    var id: String { sourceFileURL?.standardizedFileURL.path ?? displayPath }
}

struct SkillDirectoryScanResult {
    let skills: [SkillDescriptor]
}

enum SkillDirectoryScanner {
    static func scan(provider: ProviderDefinition) -> SkillDirectoryScanResult {
        var skillsByID: [String: SkillDescriptor] = [:]
        var scannedDirectories: Set<String> = []

        for path in provider.skillDirectories {
            for directoryURL in resolveDirectories(for: path) {
                guard scannedDirectories.insert(directoryURL.standardizedFileURL.path).inserted else {
                    continue
                }
                scanSkillEntries(in: directoryURL, skillsByID: &skillsByID)
            }
        }

        return SkillDirectoryScanResult(
            skills: skillsByID.values.sorted {
                $0.displayPath.localizedCaseInsensitiveCompare($1.displayPath) == .orderedAscending
            }
        )
    }

    private static func scanSkillEntries(in directoryURL: URL, skillsByID: inout [String: SkillDescriptor]) {
        let fileManager = FileManager.default
        let contents = (try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        for entry in contents {
            if (try? entry.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                if let sourceFileURL = skillFileURL(fromDirectory: entry) {
                    let snippet = extractSnippet(fromMarkdownFile: sourceFileURL)
                    let displayPath = displayPath(for: sourceFileURL)
                    skillsByID[sourceFileURL.standardizedFileURL.path] = SkillDescriptor(
                        displayPath: displayPath,
                        snippet: snippet,
                        sourceFileURL: sourceFileURL
                    )
                    continue
                }

                let nestedSkillsDirectory = entry.appendingPathComponent("skills", isDirectory: true)
                var nestedIsDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: nestedSkillsDirectory.path, isDirectory: &nestedIsDirectory),
                   nestedIsDirectory.boolValue
                {
                    scanSkillEntries(in: nestedSkillsDirectory, skillsByID: &skillsByID)
                }
                continue
            }

            let ext = entry.pathExtension.lowercased()
            if ext == "md" || ext == "txt" || ext == "skill" {
                let snippet = extractSnippet(fromMarkdownFile: entry)
                let displayPath = displayPath(for: entry)
                skillsByID[entry.standardizedFileURL.path] = SkillDescriptor(
                    displayPath: displayPath,
                    snippet: snippet,
                    sourceFileURL: entry
                )
            }
        }
    }

    private static func displayPath(for sourceFileURL: URL) -> String {
        let standardized = sourceFileURL.standardizedFileURL
        let baseURL: URL
        if standardized.lastPathComponent.lowercased() == "skill.md" {
            baseURL = standardized.deletingLastPathComponent()
        } else if standardized.pathExtension.isEmpty {
            baseURL = standardized
        } else {
            baseURL = standardized.deletingPathExtension()
        }

        let path = baseURL.path
        let homePath = NSHomeDirectory()
        if path == homePath {
            return "~"
        }
        if path.hasPrefix(homePath + "/") {
            return "~" + String(path.dropFirst(homePath.count))
        }

        let currentPath = FileManager.default.currentDirectoryPath
        if path == currentPath {
            return "."
        }
        if path.hasPrefix(currentPath + "/") {
            return "." + String(path.dropFirst(currentPath.count))
        }

        return path
    }

    private static func resolveDirectories(for rawPath: String) -> [URL] {
        let fileManager = FileManager.default
        let expandedPath = (rawPath as NSString).expandingTildeInPath

        var candidatePaths: [String] = []
        if expandedPath.hasPrefix("/") {
            candidatePaths.append(expandedPath)
        } else {
            for workspaceRoot in workspaceRoots() {
                candidatePaths.append(workspaceRoot.appendingPathComponent(expandedPath).path)
            }
        }

        var results: [URL] = []
        var seen: Set<String> = []
        for candidatePath in candidatePaths {
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: candidatePath, isDirectory: &isDirectory), isDirectory.boolValue else {
                continue
            }
            let standardized = URL(fileURLWithPath: candidatePath, isDirectory: true).standardizedFileURL
            guard seen.insert(standardized.path).inserted else { continue }
            results.append(standardized)
        }

        return results
    }

    private static func workspaceRoots() -> [URL] {
        var roots: [URL] = []
        var seen: Set<String> = []

        func appendRoot(_ url: URL) {
            let standardized = url.standardizedFileURL
            guard seen.insert(standardized.path).inserted else { return }
            roots.append(standardized)
        }

        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        var cursor = currentDirectory
        while true {
            appendRoot(cursor)
            let parent = cursor.deletingLastPathComponent()
            if parent.path == cursor.path { break }
            cursor = parent
        }

        let envRoots = (ProcessInfo.processInfo.environment["SKILLFOX_WORKSPACE_ROOTS"]
            ?? ProcessInfo.processInfo.environment["SKILLIST_WORKSPACE_ROOTS"]
            ?? "")
        if !envRoots.isEmpty {
            for root in envRoots.split(separator: ":").map(String.init).filter({ !$0.isEmpty }) {
                appendRoot(URL(fileURLWithPath: root, isDirectory: true))
            }
        }

        return roots
    }

    private static func extractSnippet(fromDirectory directoryURL: URL) -> String? {
        let skillFile = skillFileURL(fromDirectory: directoryURL) ?? directoryURL.appendingPathComponent("SKILL.md")
        return extractSnippet(fromMarkdownFile: skillFile)
    }

    private static func skillFileURL(fromDirectory directoryURL: URL) -> URL? {
        let skillFile = directoryURL.appendingPathComponent("SKILL.md")
        guard FileManager.default.fileExists(atPath: skillFile.path) else {
            return nil
        }
        return skillFile
    }

    private static func extractSnippet(fromMarkdownFile fileURL: URL) -> String? {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return nil
        }

        let (frontMatter, body) = splitFrontMatter(from: content)
        if let description = extractDescription(fromFrontMatter: frontMatter) {
            return normalizeSnippet(description)
        }

        return extractFirstParagraph(from: body)
    }

    private static func splitFrontMatter(from content: String) -> (frontMatter: String?, body: String) {
        guard content.hasPrefix("---") else {
            return (nil, content)
        }

        let lines = content.components(separatedBy: .newlines)
        guard lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) == "---" else {
            return (nil, content)
        }

        var endIndex: Int?
        for index in 1..<lines.count where lines[index].trimmingCharacters(in: .whitespacesAndNewlines) == "---" {
            endIndex = index
            break
        }

        guard let frontMatterEnd = endIndex else {
            return (nil, content)
        }

        let frontMatter = lines[1..<frontMatterEnd].joined(separator: "\n")
        let bodyStart = frontMatterEnd + 1
        let body = bodyStart < lines.count ? lines[bodyStart...].joined(separator: "\n") : ""
        return (frontMatter, body)
    }

    private static func extractDescription(fromFrontMatter frontMatter: String?) -> String? {
        guard let frontMatter else { return nil }

        for line in frontMatter.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.lowercased().hasPrefix("description:") else { continue }
            let value = trimmed.dropFirst("description:".count).trimmingCharacters(in: .whitespaces)
            let unquoted = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            if !unquoted.isEmpty {
                return unquoted
            }
        }
        return nil
    }

    private static func extractFirstParagraph(from body: String) -> String? {
        for line in body.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            guard !trimmed.hasPrefix("#"),
                  !trimmed.hasPrefix("-"),
                  !trimmed.hasPrefix("*"),
                  !trimmed.hasPrefix("```")
            else { continue }
            return normalizeSnippet(trimmed)
        }
        return nil
    }

    private static func normalizeSnippet(_ text: String) -> String {
        let compact = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        if compact.count <= 120 {
            return compact
        }
        let index = compact.index(compact.startIndex, offsetBy: 120)
        return String(compact[..<index]).trimmingCharacters(in: .whitespaces) + "…"
    }
}
