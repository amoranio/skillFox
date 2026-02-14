import AppKit
import SwiftUI

struct ProviderRowView: View {
    let provider: ProviderDefinition

    var body: some View {
        HStack(spacing: 8) {
            if let icon = ProviderBrandIcon.image(named: provider.iconResourceName) {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            Text(provider.name)
                .font(.system(size: 14, weight: .semibold))
        }
    }
}
