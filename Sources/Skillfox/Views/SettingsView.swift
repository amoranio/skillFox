import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var providerSettings: ProviderSettingsStore

    var body: some View {
        Form {
            Section("Providers") {
                ForEach(ProviderCatalog.all) { provider in
                    Toggle(
                        isOn: Binding(
                            get: { providerSettings.isEnabled(provider) },
                            set: { providerSettings.setEnabled($0, for: provider) }
                        )
                    ) {
                        ProviderRowView(provider: provider)
                    }
                    .toggleStyle(.switch)
                    .tint(.green)
                }
            }

            Section("Display") {
                Toggle(
                    "Hide providers with no skills",
                    isOn: Binding(
                        get: { providerSettings.hideProvidersWithNoSkills },
                        set: { providerSettings.setHideProvidersWithNoSkills($0) }
                    )
                )
                .toggleStyle(.switch)
                .tint(.green)
            }

            Section("App") {
                Button("Quit Skillfox", role: .destructive) {
                    NSApp.terminate(nil)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 360, idealWidth: 380, maxWidth: 480, minHeight: 220, idealHeight: 260, maxHeight: 380)
        .padding(12)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        }
    }
}
