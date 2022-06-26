import SwiftUI
import Combine

//MARK: - Main View
@available(iOS 13, macOS 11, *)
public struct AlertView: View {
    
    public enum ViewType {
        case alert, toast
    }
    
    public var isPresented: Binding<Bool>
    
    public var viewType: ViewType? = .alert
        
    public var body: some View {
        Text("SwiftUI Content")
    }
}
