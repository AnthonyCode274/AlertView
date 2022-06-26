import SwiftUI
import Combine

@available(iOS 13, macOS 11, *)
public extension View{
    /// Present `AlertToast`.
    /// - Parameters:
    ///   - show: Binding<Bool>
    ///   - alert: () -> AlertToast
    /// - Returns: `AlertToast`
    func toast(isPresenting: Binding<Bool>, duration: Double = 2, tapToDismiss: Bool = true, offsetY: CGFloat = 0, alertToast: @escaping () -> AlertToast, onTap: (() -> ())? = nil, completion: (() -> ())? = nil) -> some View{
        modifier(AlertToastModifier(isPresenting: isPresenting, duration: duration, tapToDismiss: tapToDismiss, offsetY: offsetY, alertToast: alertToast, onTap: onTap, completion: completion))
    }
}
