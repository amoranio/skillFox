import Foundation

@MainActor
final class ProviderSettingsStore: ObservableObject {
    @Published private(set) var enabledProviderIDs: Set<String>
    @Published private(set) var hideProvidersWithNoSkills: Bool

    private static let keyPrefix = "skillfox.provider.enabled."
    private static let hideEmptyProvidersKey = "skillfox.hide.empty.providers"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hideProvidersWithNoSkills = defaults.object(forKey: Self.hideEmptyProvidersKey) == nil
            ? true
            : defaults.bool(forKey: Self.hideEmptyProvidersKey)
        let keyPrefix = Self.keyPrefix
        self.enabledProviderIDs = Set(
            ProviderCatalog.all.compactMap { provider in
                let storageKey = "\(keyPrefix)\(provider.id)"
                guard defaults.object(forKey: storageKey) != nil else {
                    return nil
                }
                return defaults.bool(forKey: storageKey) ? provider.id : nil
            }
        )
    }

    func isEnabled(_ provider: ProviderDefinition) -> Bool {
        enabledProviderIDs.contains(provider.id)
    }

    func setEnabled(_ enabled: Bool, for provider: ProviderDefinition) {
        if enabled {
            enabledProviderIDs.insert(provider.id)
        } else {
            enabledProviderIDs.remove(provider.id)
        }
        defaults.set(enabled, forKey: "\(Self.keyPrefix)\(provider.id)")
    }

    func setHideProvidersWithNoSkills(_ value: Bool) {
        hideProvidersWithNoSkills = value
        defaults.set(value, forKey: Self.hideEmptyProvidersKey)
    }
}
