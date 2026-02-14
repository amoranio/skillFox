import AppKit
import SwiftUI

struct SkillfoxMenuView: View {
    @ObservedObject var providerSettings: ProviderSettingsStore
    @Environment(\.openSettings) private var openSettings
    @State private var scanResultsByProviderID: [String: SkillDirectoryScanResult] = [:]
    private let providerTextInset: CGFloat = 22
    private let repositoryURL = URL(string: "https://github.com/amoranio/skillFox")!

    private var enabledProviders: [ProviderDefinition] {
        ProviderCatalog.all.filter(providerSettings.isEnabled)
    }

    private var visibleProviders: [ProviderDefinition] {
        enabledProviders.filter { provider in
            let skills = scanResultsByProviderID[provider.id]?.skills ?? []
            return !providerSettings.hideProvidersWithNoSkills || !skills.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Link("Skillfox", destination: repositoryURL)
                    .font(.headline)
                Spacer()
                Button {
                    refreshSkills()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")

                Button {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Settings")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()

            if enabledProviders.isEmpty {
                Text("Enable providers in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
            } else if visibleProviders.isEmpty {
                Text("No skills found for enabled providers.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
            } else {
                ScrollView {
                    providerSkillsContent
                }
            }
        }
        .frame(width: 350)
        .onAppear(perform: refreshSkills)
        .onChange(of: providerSettings.enabledProviderIDs) { _, _ in
            refreshSkills()
        }
        .onChange(of: providerSettings.hideProvidersWithNoSkills) { _, _ in
            refreshSkills()
        }
    }

    private var providerSkillsContent: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(visibleProviders) { provider in
                VStack(alignment: .leading, spacing: 5) {
                    ProviderRowView(provider: provider)
                    let skills = scanResultsByProviderID[provider.id]?.skills ?? []
                    if skills.isEmpty {
                        Text("No skills found")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.leading, providerTextInset)
                    } else {
                        ForEach(skills) { skill in
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(skill.displayPath)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer(minLength: 0)
                                    if let sourceFileURL = skill.sourceFileURL {
                                        Button("Open") {
                                            NSWorkspace.shared.open(sourceFileURL)
                                        }
                                        .buttonStyle(.link)
                                        .font(.caption)
                                    }
                                }
                                if let snippet = skill.snippet, !snippet.isEmpty {
                                    Text(snippet)
                                        .font(.caption2)
                                        .italic()
                                        .foregroundStyle(.tertiary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.leading, providerTextInset)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 8)
    }

    private func refreshSkills() {
        scanResultsByProviderID = Dictionary(
            uniqueKeysWithValues: enabledProviders.map { provider in
                (provider.id, SkillDirectoryScanner.scan(provider: provider))
            }
        )
    }
}
