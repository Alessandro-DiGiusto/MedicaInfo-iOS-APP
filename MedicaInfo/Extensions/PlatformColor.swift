import SwiftUI

// MARK: - Cross-platform color helpers
extension Color {
    #if os(macOS)
    static let systemGroupedBackground = Color(nsColor: .controlBackgroundColor)
    static let systemBackground = Color(nsColor: .windowBackgroundColor)
    static let systemGray5 = Color(nsColor: .separatorColor)
    static let systemGray6 = Color(nsColor: .controlBackgroundColor)
    #endif
}
