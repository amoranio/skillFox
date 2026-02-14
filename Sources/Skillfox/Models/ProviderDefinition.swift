import SwiftUI

struct ProviderDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let iconResourceName: String
    let tintHex: String
    let skillDirectories: [String]

    var tintColor: Color {
        Color(hex: tintHex)
    }
}
