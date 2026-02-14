import AppKit

enum ProviderBrandIcon {
    static func image(named resourceName: String) -> NSImage? {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: "svg"),
              let image = NSImage(contentsOf: url)
        else {
            return nil
        }

        image.size = NSSize(width: 14, height: 14)
        image.isTemplate = true
        return image
    }
}
