import AppKit
import SwiftUI

@main
struct SkillfoxApp: App {
    @StateObject private var providerSettings = ProviderSettingsStore()

    var body: some Scene {
        MenuBarExtra {
            SkillfoxMenuView(providerSettings: providerSettings)
        } label: {
            toolbarIcon
                .contextMenu {
                    Button("Open Skillfox") {
                        openApp()
                    }
                    Divider()
                    Button("Quit Skillfox", role: .destructive) {
                        NSApp.terminate(nil)
                    }
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(providerSettings: providerSettings)
        }
    }

    @ViewBuilder
    private var toolbarIcon: some View {
        if let image = loadToolbarImage() {
            Image(nsImage: image)
                .renderingMode(.template)
        } else {
            Image(systemName: "slider.horizontal.3")
        }
    }

    private func loadToolbarImage() -> NSImage? {
        if let pngURL = Bundle.module.url(forResource: "skillfox", withExtension: "png"),
           let pngImage = NSImage(contentsOf: pngURL) {
            pngImage.isTemplate = true
            pngImage.size = NSSize(width: 18, height: 18)
            return pngImage
        }
        return nil
    }

    private func openApp() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
