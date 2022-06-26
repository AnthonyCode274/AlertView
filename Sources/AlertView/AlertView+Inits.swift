import SwiftUI
import Combine

@available(iOS 13, macOS 11, *)
extension AlertView {
    /// Present `AlertView`.
    /// - Parameters:
    ///   - isPresented: Binding<Bool>
    ///   - viewType: ViewType? = .alert
    /// - Returns: `AlertToast`
    public init(isPresented: Binding<Bool>, viewType: ViewType? = .alert) {
        self.isPresented = isPresented
        self.viewType = viewType
    }
}
